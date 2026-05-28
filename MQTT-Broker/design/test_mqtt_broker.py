import argparse
import queue
import socket
import ssl
import time
import uuid

import paho.mqtt.client as mqtt


HOST = "127.0.0.1"
PORT = 1883
USE_TLS = False
USERNAME = None
PASSWORD = None


def make_client(protocol, name, messages=None, tls=None, username=None, password=None):
    kwargs = {
        "callback_api_version": mqtt.CallbackAPIVersion.VERSION2,
        "client_id": f"{name}-{uuid.uuid4().hex[:8]}",
        "protocol": protocol,
    }
    if protocol == mqtt.MQTTv311:
        kwargs["clean_session"] = True
    client = mqtt.Client(**kwargs)
    if username is None:
        username = USERNAME
        password = PASSWORD
    if username is not None:
        client.username_pw_set(username, password)
    connected = {"event": None}
    subscribed = {"event": None}
    disconnected = {"event": None}

    def on_connect(client, userdata, flags, reason_code, properties):
        connected["event"] = reason_code

    def on_subscribe(client, userdata, mid, reason_codes, properties):
        subscribed["event"] = reason_codes

    def on_disconnect(client, userdata, flags, reason_code, properties):
        disconnected["event"] = reason_code

    def on_message(client, userdata, message):
        if messages is not None:
            messages.put((message.topic, message.payload))

    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    if tls is None:
        tls = USE_TLS
    if tls:
        client.tls_set(cert_reqs=ssl.CERT_NONE)
        client.tls_insecure_set(True)
    return client, connected, subscribed, disconnected


def wait_for(predicate, timeout=5.0, label="condition"):
    end = time.time() + timeout
    while time.time() < end:
        value = predicate()
        if value:
            return value
        time.sleep(0.02)
    raise AssertionError(f"timed out waiting for {label}")


def reason_ok(reason_code):
    return reason_code == 0 or str(reason_code) == "Success"


def connect_client(client, protocol, host=None, port=None):
    host = host or HOST
    port = port or PORT
    if protocol == mqtt.MQTTv5:
        client.connect(host, port, keepalive=10, clean_start=mqtt.MQTT_CLEAN_START_FIRST_ONLY)
    else:
        client.connect(host, port, keepalive=10)
    client.loop_start()


def connect_and_wait(client, connected, protocol, label, host=None, port=None, expect_ok=True):
    connect_client(client, protocol, host=host, port=port)
    wait_for(lambda: connected["event"] is not None, label=f"{label} connect")
    if expect_ok:
        assert reason_ok(connected["event"]), f"{label} connect failed: {connected['event']}"
    else:
        assert not reason_ok(connected["event"]), f"{label} unexpectedly connected"


def run_delivery_case(protocol, label):
    messages = queue.Queue()
    sub, sub_connected, sub_subscribed, sub_disconnected = make_client(protocol, f"sub-{label}", messages)
    pub, pub_connected, _, _ = make_client(protocol, f"pub-{label}")
    try:
        connect_and_wait(sub, sub_connected, protocol, f"{label} subscriber")
        result, mid = sub.subscribe("test/+", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        wait_for(
            lambda: sub_subscribed["event"] is not None or sub_disconnected["event"] is not None,
            label=f"{label} subscribe or disconnect",
        )
        assert sub_subscribed["event"] is not None, f"{label} disconnected before SUBACK: {sub_disconnected['event']}"

        connect_and_wait(pub, pub_connected, protocol, f"{label} publisher")
        info = pub.publish("test/one", f"payload-{label}".encode("ascii"), qos=0, retain=False)
        info.wait_for_publish(timeout=5)

        topic, payload = messages.get(timeout=5)
        assert topic == "test/one"
        assert payload == f"payload-{label}".encode("ascii")
    finally:
        pub.disconnect()
        sub.disconnect()
        pub.loop_stop()
        sub.loop_stop()


def run_hash_case(protocol, label):
    messages = queue.Queue()
    sub, sub_connected, sub_subscribed, sub_disconnected = make_client(protocol, f"hash-sub-{label}", messages)
    pub, pub_connected, _, _ = make_client(protocol, f"hash-pub-{label}")
    try:
        connect_and_wait(sub, sub_connected, protocol, f"{label} hash subscriber")
        result, mid = sub.subscribe("hash/#", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        wait_for(
            lambda: sub_subscribed["event"] is not None or sub_disconnected["event"] is not None,
            label=f"{label} hash subscribe or disconnect",
        )
        assert sub_subscribed["event"] is not None, f"{label} disconnected before hash SUBACK: {sub_disconnected['event']}"

        connect_and_wait(pub, pub_connected, protocol, f"{label} hash publisher")
        info = pub.publish("hash/a/b", b"hash-payload", qos=0, retain=False)
        info.wait_for_publish(timeout=5)

        topic, payload = messages.get(timeout=5)
        assert topic == "hash/a/b"
        assert payload == b"hash-payload"
    finally:
        pub.disconnect()
        sub.disconnect()
        pub.loop_stop()
        sub.loop_stop()


def run_dollar_case(protocol, label):
    messages = queue.Queue()
    sub, sub_connected, sub_subscribed, sub_disconnected = make_client(protocol, f"dollar-sub-{label}", messages)
    pub, pub_connected, _, _ = make_client(protocol, f"dollar-pub-{label}")
    try:
        connect_and_wait(sub, sub_connected, protocol, f"{label} dollar subscriber")
        result, mid = sub.subscribe("#", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        wait_for(
            lambda: sub_subscribed["event"] is not None or sub_disconnected["event"] is not None,
            label=f"{label} dollar subscribe or disconnect",
        )
        assert sub_subscribed["event"] is not None, f"{label} disconnected before dollar SUBACK: {sub_disconnected['event']}"

        connect_and_wait(pub, pub_connected, protocol, f"{label} dollar publisher")
        info = pub.publish("$SYS/test", b"hidden", qos=0, retain=False)
        info.wait_for_publish(timeout=5)

        try:
            topic, payload = messages.get(timeout=0.5)
        except queue.Empty:
            return
        raise AssertionError(f"{label}: # unexpectedly matched {topic!r} with {payload!r}")
    finally:
        pub.disconnect()
        sub.disconnect()
        pub.loop_stop()
        sub.loop_stop()


def run_onpublish_case(protocol, label):
    messages = queue.Queue()
    sub, sub_connected, sub_subscribed, _ = make_client(protocol, f"policy-sub-{label}", messages)
    pub, pub_connected, _, _ = make_client(protocol, f"policy-pub-{label}")
    try:
        connect_and_wait(sub, sub_connected, protocol, f"{label} onpublish subscriber")
        result, mid = sub.subscribe("blocked/#", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        result, mid = sub.subscribe("allowed/#", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        wait_for(lambda: sub_subscribed["event"] is not None, label=f"{label} onpublish subscribe")

        connect_and_wait(pub, pub_connected, protocol, f"{label} onpublish publisher")
        info = pub.publish("blocked/deny", b"blocked", qos=0, retain=False)
        info.wait_for_publish(timeout=5)
        try:
            topic, payload = messages.get(timeout=0.5)
        except queue.Empty:
            pass
        else:
            raise AssertionError(f"{label}: blocked publish was routed as {topic!r} {payload!r}")

        info = pub.publish("allowed/pass", b"allowed", qos=0, retain=False)
        info.wait_for_publish(timeout=5)
        topic, payload = messages.get(timeout=5)
        assert topic == "allowed/pass"
        assert payload == b"allowed"
    finally:
        pub.disconnect()
        sub.disconnect()
        pub.loop_stop()
        sub.loop_stop()


def run_auth_case(protocol, label):
    good, good_connected, _, _ = make_client(
        protocol, f"auth-good-{label}", username="mqttuser", password="mqttpass"
    )
    bad, bad_connected, _, bad_disconnected = make_client(
        protocol, f"auth-bad-{label}", username="mqttuser", password="wrong"
    )
    try:
        connect_and_wait(good, good_connected, protocol, f"{label} good auth")
        connect_client(bad, protocol)
        wait_for(
            lambda: bad_connected["event"] is not None or bad_disconnected["event"] is not None,
            label=f"{label} bad auth result",
        )
        assert bad_connected["event"] is not None, f"{label} bad auth disconnected without CONNACK"
        assert not reason_ok(bad_connected["event"]), f"{label} bad auth unexpectedly succeeded"
    finally:
        good.disconnect()
        bad.disconnect()
        good.loop_stop()
        bad.loop_stop()


def run_dual_case(protocol, label, plain_port, tls_port):
    messages = queue.Queue()
    sub, sub_connected, sub_subscribed, _ = make_client(
        protocol, f"dual-plain-sub-{label}", messages, tls=False
    )
    pub, pub_connected, _, _ = make_client(protocol, f"dual-tls-pub-{label}", tls=True)
    try:
        connect_and_wait(sub, sub_connected, protocol, f"{label} dual plain subscriber", port=plain_port)
        result, mid = sub.subscribe("dual/+", qos=0)
        assert result == mqtt.MQTT_ERR_SUCCESS
        wait_for(lambda: sub_subscribed["event"] is not None, label=f"{label} dual subscribe")

        connect_and_wait(pub, pub_connected, protocol, f"{label} dual tls publisher", port=tls_port)
        info = pub.publish("dual/route", f"dual-{label}".encode("ascii"), qos=0, retain=False)
        info.wait_for_publish(timeout=5)

        topic, payload = messages.get(timeout=5)
        assert topic == "dual/route"
        assert payload == f"dual-{label}".encode("ascii")
    finally:
        pub.disconnect()
        sub.disconnect()
        pub.loop_stop()
        sub.loop_stop()


def enc_string(value):
    raw = value.encode("utf-8") if isinstance(value, str) else value
    return len(raw).to_bytes(2, "big") + raw


def enc_vbint(value):
    out = bytearray()
    while True:
        digit = value % 128
        value //= 128
        if value:
            digit |= 128
        out.append(digit)
        if not value:
            return bytes(out)


def packet(packet_type, payload=b""):
    return bytes([packet_type]) + enc_vbint(len(payload)) + payload


def raw_connect_packet(protocol_level=4, client_id=None):
    client_id = client_id or f"raw-{uuid.uuid4().hex[:8]}"
    vh = enc_string("MQTT") + bytes([protocol_level, 0x02, 0, 10])
    if protocol_level == 5:
        vh += b"\x00"
    return packet(0x10, vh + enc_string(client_id))


def open_raw_socket(host=None, port=None, tls=None):
    host = host or HOST
    port = port or PORT
    if tls is None:
        tls = USE_TLS
    sock = socket.create_connection((host, port), timeout=5)
    if tls:
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        sock = ctx.wrap_socket(sock, server_hostname=host)
    sock.settimeout(5)
    return sock


def raw_connack(sock):
    data = sock.recv(8)
    assert data and data[0] == 0x20, f"expected CONNACK, got {data!r}"
    return data


def run_raw_negative_cases():
    with open_raw_socket() as sock:
        sock.sendall(raw_connect_packet(4))
        raw_connack(sock)
        payload = enc_string("qos1/topic") + b"\x00\x01" + b"bad"
        sock.sendall(packet(0x32, payload))
        data = sock.recv(8)
        assert data == b"", f"QoS 1 PUBLISH should close connection, got {data!r}"
    print("raw: qos1 publish reject ok")

    with open_raw_socket() as sock:
        sock.sendall(raw_connect_packet(4))
        raw_connack(sock)
        sub_payload = b"\x00\x01" + enc_string("bad/#/x") + b"\x00"
        sock.sendall(packet(0x82, sub_payload))
        data = sock.recv(8)
        assert data == b"\x90\x03\x00\x01\x80", f"invalid filter SUBACK mismatch: {data!r}"
    print("raw: invalid wildcard suback ok")

    with open_raw_socket() as sock:
        sock.sendall(raw_connect_packet(5))
        raw_connack(sock)
        publish_payload = enc_string("alias/topic") + b"\x03\x23\x00\x01"
        sock.sendall(packet(0x30, publish_payload))
        data = sock.recv(8)
        assert data[:2] == b"\xe0\x02", f"MQTT 5 topic alias should get DISCONNECT, got {data!r}"
    print("raw: mqtt5 topic alias reject ok")


def run_no_wildcard_cases(port):
    with open_raw_socket(port=port, tls=False) as sock:
        sock.sendall(raw_connect_packet(4))
        raw_connack(sock)
        sub_payload = b"\x00\x01" + enc_string("exact/topic") + b"\x00"
        sock.sendall(packet(0x82, sub_payload))
        data = sock.recv(8)
        assert data == b"\x90\x03\x00\x01\x00", f"exact SUBACK mismatch: {data!r}"
    print("raw: no-wildcard exact subscribe ok")

    with open_raw_socket(port=port, tls=False) as sock:
        sock.sendall(raw_connect_packet(4))
        raw_connack(sock)
        sub_payload = b"\x00\x01" + enc_string("exact/+") + b"\x00"
        sock.sendall(packet(0x82, sub_payload))
        data = sock.recv(8)
        assert data == b"\x90\x03\x00\x01\x80", f"MQTT 3.1.1 wildcard reject mismatch: {data!r}"
    print("raw: mqtt311 wildcard disabled ok")

    with open_raw_socket(port=port, tls=False) as sock:
        sock.sendall(raw_connect_packet(5))
        raw_connack(sock)
        sub_payload = b"\x00\x01\x00" + enc_string("exact/+") + b"\x00"
        sock.sendall(packet(0x82, sub_payload))
        data = sock.recv(8)
        assert data == b"\x90\x04\x00\x01\x00\xa2", f"MQTT 5 wildcard reject mismatch: {data!r}"
    print("raw: mqtt5 wildcard disabled ok")


def main():
    global HOST, PORT, USE_TLS, USERNAME, PASSWORD
    parser = argparse.ArgumentParser(description="paho-mqtt integration tests for mqttbroker.lua")
    parser.add_argument("--host", default=HOST)
    parser.add_argument("--port", type=int, default=PORT)
    parser.add_argument("--tls", action="store_true", help="connect with TLS and accept any server certificate")
    parser.add_argument("--username")
    parser.add_argument("--password")
    parser.add_argument("--auth", action="store_true", help="run auth callback accept/reject tests")
    parser.add_argument("--negative", action="store_true", help="run raw negative protocol tests")
    parser.add_argument("--dual", action="store_true", help="run cross-listener plain/TLS routing tests")
    parser.add_argument("--onpublish", action="store_true", help="run publish policy callback tests")
    parser.add_argument("--no-wildcards", action="store_true", help="run allowWildcards=false tests")
    parser.add_argument("--plain-port", type=int, default=1883)
    parser.add_argument("--tls-port", type=int, default=8883)
    parser.add_argument("--no-wildcard-port", type=int, default=1884)
    parser.add_argument("--all", action="store_true", help="run delivery, auth, negative, and dual tests")
    args = parser.parse_args()
    HOST = args.host
    PORT = args.port
    USE_TLS = args.tls
    USERNAME = args.username
    PASSWORD = args.password

    cases = [
        (mqtt.MQTTv311, "mqtt311"),
        (mqtt.MQTTv5, "mqtt5"),
    ]
    for protocol, label in cases:
        run_delivery_case(protocol, label)
        print(f"{label}: delivery ok")
        run_hash_case(protocol, label)
        print(f"{label}: hash wildcard ok")
        run_dollar_case(protocol, label)
        print(f"{label}: dollar wildcard rule ok")
        if args.onpublish or args.all:
            run_onpublish_case(protocol, label)
            print(f"{label}: onpublish callback ok")
        if args.auth or args.all:
            run_auth_case(protocol, label)
            print(f"{label}: auth callback ok")
        if args.dual or args.all:
            run_dual_case(protocol, label, args.plain_port, args.tls_port)
            print(f"{label}: dual listener routing ok")

    if args.negative or args.all:
        run_raw_negative_cases()
# This test requires a broker with allowWildcards=false
#    if args.no_wildcards or args.all:
#        run_no_wildcard_cases(args.no_wildcard_port)


if __name__ == "__main__":
    main()
