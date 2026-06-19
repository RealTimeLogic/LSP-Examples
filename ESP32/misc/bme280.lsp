<?lsp
-- ============================================================================
-- BME280 Monolithic Telemetry Station & API Engine
-- Tutorial: https://realtimelogic.com/articles/Vibe-Coding-Embedded-Web-Interfaces
-- Context: Combined hardware controller and responsive UI delivery.
-- ============================================================================

-- OPTIMIZATION: Initialize the sensor once and store it in the persistent app container
if not app.bme then
    local PORT <const> = 0          -- High-Performance I2C Port
    local BME280_ADDR <const> = 0x76 -- Default BME280 I2C Register Node
    local SDA_GPIO <const> = 7      -- ESP_I2C_SDA (Pin 3 on J10)
    local SCL_GPIO <const> = 8      -- ESP_I2C_SCL (Pin 4 on J10)

    local settings = {
        tStandby = 1,
        filter = 4,
        pressOverSample = 5,
        humidOverSample = 1,
        tempOverSample = 2
    }

    -- Safely call the local driver module
    local bme, err = require"bme280".create(PORT, BME280_ADDR, SDA_GPIO, SCL_GPIO, settings)
    
    if bme then
        app.bme = bme
        app.enabled = true
        app.status = "Active"
        -- Warm up allocation tables with baseline values
        app.cached_temp = 0.0
        app.cached_hum = 0.0
        app.cached_pres = 0.0
        trace("SUCCESS: BME280 monolithic instance attached to persistent application context.")
    else
        trace("CRITICAL: Failed to link BME280 hardware layer: ", err)
    end
end

-- Read execution verbs routed from Client-Side JavaScript Data Layer
local action = request:data("action")

-- REST API Endpoint: Query active values on demand
if action == "get_data" then
    response:setcontenttype("application/json")
    
    if app.bme and app.enabled then
        local temperature, humidity, pressure = app.bme:read()
        if temperature then
            app.cached_temp = temperature
            app.cached_hum = humidity
            app.cached_pres = pressure / 100 -- Convert Pascals to hPa
            app.status = "Active"
        else
            app.status = "Read Error"
            trace("WARNING: Hardware register parsing failed on I2C bus.")
        end
    elseif not app.enabled then
        app.status = "Paused"
    end

    local payload = {
        success = (app.bme ~= nil),
        temperature = app.cached_temp,
        humidity = app.cached_hum,
        pressure = app.cached_pres,
        status = app.status,
        enabled = app.enabled
    }
    response:write(ba.json.encode(payload))
    return -- Intercept lifecycle execution to prevent HTML injection into JSON buffer
end

-- REST API Endpoint: Toggle active register querying on/off
if action == "toggle_capture" then
    response:setcontenttype("application/json")
    if app.bme then
        app.enabled = not app.enabled
        app.status = app.enabled and "Active" or "Paused"
    end
    local payload = {
        success = (app.bme ~= nil),
        enabled = app.enabled,
        status = app.status
    }
    response:write(ba.json.encode(payload))
    return 
end
?>
<!DOCTYPE html>
<html lang="en" class="h-full bg-slate-950 text-slate-50">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESP32-P4 Monolithic Telemetry Station</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="h-full font-sans antialiased">

    <div class="min-h-full flex flex-col justify-between max-w-6xl mx-auto p-4 md:p-8 space-y-6">
        
        <header class="flex flex-col sm:flex-row justify-between items-start sm:items-center pb-6 border-b border-slate-800 gap-4">
            <div>
                <h1 class="text-3xl font-extrabold tracking-tight bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">
                    ESP32-P4 Telemetry Core
                </h1>
                <p class="text-xs text-slate-400 font-mono mt-1">Hardware Bus: Monolithic Single-File Node (J10 Interface)</p>
            </div>
            
            <div class="flex flex-wrap items-center gap-4 bg-slate-900 p-2 rounded-xl border border-slate-800">
                <div class="flex items-center space-x-2 bg-slate-950 px-3 py-1 rounded-lg border border-slate-800">
                    <label for="interval-select" class="text-xs font-mono font-semibold text-slate-400">Rate:</label>
                    <select id="interval-select" onchange="changeSamplingRate(this.value)" class="bg-transparent text-slate-200 text-xs font-mono focus:outline-none cursor-pointer">
                        <option value="1000" class="bg-slate-900">1s (Fast)</option>
                        <option value="2000" selected class="bg-slate-900">2s (Normal)</option>
                        <option value="5000" class="bg-slate-900">5s (Slow)</option>
                        <option value="10000" class="bg-slate-900">10s (Eco)</option>
                    </select>
                </div>

                <div class="flex items-center space-x-2 px-2">
                    <span id="status-pulse" class="h-2.5 w-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    <span id="status-text" class="text-xs font-mono font-bold uppercase tracking-wider text-slate-300">Active</span>
                </div>
                <button id="toggle-btn" onclick="toggleCapture()" class="px-4 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 transition-colors font-semibold text-sm shadow-lg shadow-rose-900/30">
                    Stop Capture
                </button>
            </div>
        </header>

        <section class="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-6">
            <div class="bg-slate-900 rounded-2xl p-6 border border-slate-800/80 shadow-xl">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">Temperature</p>
                <div class="flex items-baseline space-x-1">
                    <span id="val-temp" class="text-4xl font-mono font-bold text-cyan-400">0.00</span>
                    <span class="text-lg font-medium text-slate-500">&deg;C</span>
                </div>
            </div>
            <div class="bg-slate-900 rounded-2xl p-6 border border-slate-800/80 shadow-xl">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">Humidity</p>
                <div class="flex items-baseline space-x-1">
                    <span id="val-hum" class="text-4xl font-mono font-bold text-emerald-400">0.00</span>
                    <span class="text-lg font-medium text-slate-500">%</span>
                </div>
            </div>
            <div class="bg-slate-900 rounded-2xl p-6 border border-slate-800/80 shadow-xl">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">Barometric Pressure</p>
                <div class="flex items-baseline space-x-1">
                    <span id="val-pres" class="text-4xl font-mono font-bold text-violet-400">0.00</span>
                    <span class="text-lg font-medium text-slate-500">hPa</span>
                </div>
            </div>
        </section>

        <main class="bg-slate-900 rounded-2xl p-4 md:p-6 border border-slate-800 shadow-2xl h-96">
            <canvas id="telemetryChart" class="w-full h-full"></canvas>
        </main>

        <footer class="text-center text-xs text-slate-600 font-mono pt-4">
            Powered by Barracuda App Server Monolithic LSP Architecture (ESP32-P4).
        </footer>
    </div>

    <script>
        const maxDataPoints = 30; 
        let isCaptureEnabled = true;
        let fetchIntervalId = null;
        let activeSamplingRate = 2000; // Baseline default sampling rate in milliseconds

        // Initialize empty charts with sleek design variables
        const ctx = document.getElementById('telemetryChart').getContext('2d');
        const telemetryChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: 'Temperature (°C)',
                        borderColor: '#22d3ee',
                        backgroundColor: 'rgba(34, 211, 238, 0.05)',
                        data: [],
                        borderWidth: 2,
                        tension: 0.3,
                        yAxisID: 'y-temp'
                    },
                    {
                        label: 'Humidity (%)',
                        borderColor: '#34d399',
                        backgroundColor: 'rgba(52, 211, 153, 0.05)',
                        data: [],
                        borderWidth: 2,
                        tension: 0.3,
                        yAxisID: 'y-hum'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { labels: { color: '#94a3b8', font: { family: 'monospace' } } }
                },
                scales: {
                    x: { grid: { color: '#1e293b' }, ticks: { color: '#64748b', font: { family: 'monospace' } } },
                    'y-temp': { type: 'linear', position: 'left', grid: { color: '#1e293b' }, ticks: { color: '#22d3ee' } },
                    'y-hum': { type: 'linear', position: 'right', grid: { drawOnChartArea: false }, ticks: { color: '#34d399' } }
                }
            }
        });

        // Query the monolithic state machine endpoint
        async function fetchTelemetry() {
            try {
                const response = await fetch('?action=get_data');
                const data = await response.json();
                
                if (!data.success) return;

                // Update real-time metric numbers
                document.getElementById('val-temp').innerText = data.temperature.toFixed(2);
                document.getElementById('val-hum').innerText = data.humidity.toFixed(2);
                document.getElementById('val-pres').innerText = data.pressure.toFixed(2);
                
                isCaptureEnabled = data.enabled;
                updateStatusUI(data.enabled, data.status);

                if (data.enabled) {
                    const timestamp = new Date().toLocaleTimeString();
                    
                    telemetryChart.data.labels.push(timestamp);
                    telemetryChart.data.datasets[0].data.push(data.temperature);
                    telemetryChart.data.datasets[1].data.push(data.humidity);

                    if (telemetryChart.data.labels.length > maxDataPoints) {
                        telemetryChart.data.labels.shift();
                        telemetryChart.data.datasets[0].data.shift();
                        telemetryChart.data.datasets[1].data.shift();
                    }
                    telemetryChart.update('none'); 
                }
            } catch (error) {
                console.error("Failed to fetch data from monolithic endpoint:", error);
            }
        }

        // Dynamically shift the timing loop without reloading the page context
        function changeSamplingRate(newRateMs) {
            activeSamplingRate = parseInt(newRateMs, 10);
            
            // Clear the existing runtime scheduler hook
            clearInterval(fetchIntervalId);
            
            // Re-bind the sequencer loop with the newly selected velocity threshold
            fetchIntervalId = setInterval(fetchTelemetry, activeSamplingRate);
            console.log("Polling sequence adjusted to: " + activeSamplingRate + "ms");
        }

        // Trigger capture loop status modification
        async function toggleCapture() {
            try {
                const response = await fetch('?action=toggle_capture');
                const data = await response.json();
                if(data.success) {
                    isCaptureEnabled = data.enabled;
                    updateStatusUI(data.enabled, data.status);
                }
            } catch (error) {
                console.error("Failed to post toggle statement:", error);
            }
        }

        function updateStatusUI(enabled, status) {
            const pulse = document.getElementById('status-pulse');
            const text = document.getElementById('status-text');
            const btn = document.getElementById('toggle-btn');
            const rateSelect = document.getElementById('interval-select');

            text.innerText = status;

            if (enabled) {
                pulse.className = "h-2.5 w-2.5 rounded-full bg-emerald-500 animate-pulse";
                btn.innerText = "Stop Capture";
                btn.className = "px-4 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 transition-colors font-semibold text-sm shadow-lg shadow-rose-900/30";
                rateSelect.disabled = false;
            } else {
                pulse.className = "h-2.5 w-2.5 rounded-full bg-amber-500";
                btn.innerText = "Start Capture";
                btn.className = "px-4 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 transition-colors font-semibold text-sm shadow-lg shadow-emerald-900/30";
                rateSelect.disabled = true; // Freeze interval manipulation when capture is offline
            }
        }

        // Initialize polling sequencer (runs strictly inside client browser sandbox)
        fetchIntervalId = setInterval(fetchTelemetry, activeSamplingRate);
        fetchTelemetry(); 
    </script>
</body>
</html>
