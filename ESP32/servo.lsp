Most servo motors are not continuous; that is, they cannot rotate all
the way around but rather just over an angle of about 180 degrees.

The position of the servo motor is set by the pulse width of a signal
that is sent to the servo. The servo expects to receive a pulse with a
width between 1 and 2 milliseconds, repeated every 20 milliseconds. If
the pulse width is 1 millisecond, the servo will be at its minimum
angle; if it is 1.5 milliseconds, it will be at its center position
(which can vary between different servo models); and if it is 2
milliseconds, it will be at its maximum angle, which is usually 180
degrees (but could be up to 360 degrees for some servos).

The ratio of pulse width to cycle time is not exactly 1/20 for zero
angle and 2/20 for 180 degrees. The actual ratio will depend on the
specific cycle time used, which is usually 20 milliseconds, but could
be different in some cases.

To generate the PWM signal that controls the servo, you can use the
LEDC module in ESP-IDF. The duty cycle of the PWM signal represents
the percentage of time that the signal is high (i.e., the pulse
width), and can be calculated based on the desired pulse width and the
cycle time. The duty cycle is calculated in bits, with the maximum
value being 2^bits - 1. The duty cycle for the zero angle will be
(2^bits / cycle time) * pulse width for the minimum angle, and the
duty cycle for the maximum angle will be (2^bits / cycle time) * pulse
width for the maximum angle.

The following program shows how to calculate the PWM duty cycle

local bits=13 -- pwm resolution = 13 bits
local maxPwm=2^bits - 1 -- any value between 0 and maxPwm
local minPulseWidth = 1000  -- 1 ms
local maxPulseWidth = 2000  -- 2 ms
local minAngle = 0           -- 0 degrees
local maxAngle = 180         -- 180 degrees
local cycleTime = 20000      -- 20 ms

local function calculatePwmDutyCycle(angle)
   local pulseWidth = ((angle - minAngle) * (maxPulseWidth - minPulseWidth) / (maxAngle - minAngle)) + minPulseWidth
   return (maxPwm / cycleTime) * pulseWidth
end

We can simplify the above:

local bits=13 -- pwm resolution = 13 bits
local maxPwm=2^bits - 1 -- any value between 0 and maxPwm
local minPulseWidth = 1000  -- 1 ms
local cycleTime = 20000      -- 20 ms

local function calculatePwmDutyCycle(angle)
   return (maxPwm / cycleTime) * (angle * 1000 / 180 + minPulseWidth)
end

How to wire the servos:

See the introduction in the following tutorial on how to physically
connect a servo to the ESP32:
https://randomnerdtutorials.com/esp32-servo-motor-web-server-arduino-ide/
In short, the 3 cable servo connector:
Wire	Color
-------------
Power	Red
GND	Black, or brown
Signal	Yellow, orange, or white

A standard servo requires 4.8V so you need to connect the Servo's power to
5V on the ESP32. The signal pin goes to GPIO 25 (see details below)

You can start and stop the timer by refreshing the browser window (or
click the run button in the IDE).

Change 'gpioPin' in the code if you want to use a GPIO other than 14

<?lsp
collectgarbage()
response:setcontenttype"text/plain"

local gpioPin=14 -- You may have to change the GPIO number

local fmt=string.format
local function printf(s,...) tracep(false,5,fmt(s,...)) end

local bits=13 -- pwm resolution = 13 bits
local maxPwm=2^bits - 1 -- any value between 0 and maxPwm
local minPulseWidth = 1000  -- 1 ms
local cycleTime = 20000      -- 20 ms

local function calculatePwmDutyCycle(angle)
   return (maxPwm / cycleTime) * (angle * 1000 / 180 + minPulseWidth)
end

-- The following function runs as a coroutine timer.
-- timer: https://realtimelogic.com/ba/doc/?url=lua.html#ba_timer
local function servo()
   local ok,err=esp32.ledtimer{
      mode="LOW", -- speed_mode
      bits=bits, -- duty_resolution (bits)
      timer=0, -- timer_num
      freq=50, 
   }
   trace(ok,err)
   if ok then
      local duty = 2000 / 20000 * 100
      local led,err=esp32.ledchannel{
         mode="LOW",
         channel=1,
         timer=0, -- timer_sel
         gpio=14,
         duty = calculatePwmDutyCycle(180),
         hpoint=0,
      }
      trace(ok,err)
      if ok then
         while true do
            for angle=0,180 do
               local pwmDuty = calculatePwmDutyCycle(angle)
               printf("Angle of rotation: %d, PWM Duty Cycle: %d : %%%2.1f", angle, pwmDuty, pwmDuty/maxPwm*100);
               --printf("Angle of rotation: %d, PWM Duty Cycle", 0);
               led:duty(pwmDuty)
               coroutine.yield(true) -- Sleep
            end
         end
      end
   end
end

-- Persistent data can be saved in the 'page' table.
-- See the following for 'page' table information:
--  https://realtimelogic.com/ba/doc/?url=lua.html#CMDE
if page.timer then
   page.timer:cancel()
   page.timer=nil
   print"Stopping timer"
else
   page.timer=ba.timer(servo)
   page.timer:set(100)
   print"Starting timer"
end
?>
