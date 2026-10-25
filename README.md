# Arduino Ultrasonic Radar Scanner 

An Arduino Uno R3, HC-SR04 ultrasonic sensor, and SG90 servo create a radar-style scanner. The Arduino sweeps the sensor, measures distance, and sends angle/distance records over USB serial. A Processing sketch reads those records and draws a radar-style display on the computer.

> **Note:** This is an ultrasonic scanner, not a radio-frequency radar. It uses sound waves to estimate distance.

## Features

- Commands the servo through angles **15° to 165°**, then sweeps back down from **165° to 16°**.
- Measures distance with the HC-SR04 at each commanded angle.
- Sends serial data at **9600 baud**.
- Uses a **24,000 µs** `pulseIn()` timeout.
- Returns `400` when no echo is received before the timeout. `400` is a timeout sentinel, not a confirmed 400 cm reading.
- Draws a 1200 × 700 radar interface in Processing.
- Shows the scan line and marks distances under 40 cm in the Processing display.

## Hardware Required

- Arduino Uno R3 (or compatible board using the same pin assignments)
- HC-SR04 ultrasonic sensor
- SG90 micro servo motor
- USB cable
- Jumper wires
- Computer running Arduino IDE and Processing

A regulated external 5 V supply suitable for the servo's peak current is recommended for a physical build. If using a separate servo supply, connect its negative/ground to Arduino GND. Do not connect the external supply's positive terminal to the Arduino 5 V pin.

## Pin Connections

The pin numbers below are taken from `Radar_Arduino(1).ino`.

### HC-SR04 ultrasonic sensor

| HC-SR04 pin | Arduino Uno pin | Purpose |
|---|---|---|
| VCC | 5V | Sensor power |
| TRIG | D11 | Starts an ultrasonic pulse |
| ECHO | D9 | Reads the echo pulse |
| GND | GND | Ground |

### SG90 servo motor

| Typical servo wire | Arduino / supply connection | Purpose |
|---|---|---|
| Signal (usually orange/yellow) | D12 | Servo position control |
| +5 V (usually red) | Regulated 5 V supply recommended | Servo power |
| Ground (usually brown/black) | Supply ground and Arduino GND | Common ground |

Wire colors can vary; check the labels or documentation for your specific servo.

### Power and wiring notes

1. Connect the HC-SR04 to 5V, GND, D11 (`TRIG`), and D9 (`ECHO`).
2. Connect the servo signal wire to D12.
3. For a physical build, power the servo from a regulated 5 V supply able to handle its current peaks.
4. Connect Arduino GND, sensor GND, and external servo-supply negative together.
5. Check polarity and wiring before powering the circuit.

**Diagram check:** Ensure the circuit diagram you commit to the repository shows **TRIG → D11, ECHO → D9, and servo signal → D12**. The source code is the authority for these pin assignments.

## Software Requirements

### Arduino side

- Arduino IDE
- The Arduino `Servo` library (`#include <Servo.h>`; normally available with the IDE)
- USB serial connection to the computer

No other Arduino library is included or required by the supplied Arduino sketch.

### Processing side

- Processing IDE
- Processing's `processing.serial` library, imported by `import processing.serial.*;`
- A serial port named **`COM3`**, as hard-coded in the supplied Processing sketch
- Serial communication configured for **9600 baud**

The Processing sketch currently opens `COM3` directly. If your Arduino is assigned another port, change `"COM3"` in `new Serial(this, "COM3", 9600)` to the correct port name before running the sketch. Close the Arduino Serial Monitor before starting Processing, because the two applications generally cannot use the same serial port simultaneously.

## Project Files

Keep the project organized like this:

```text
Arduino-Radar-System/
├── Arduino/
│   └── Radar_Arduino.ino
├── Processing/
│   └── Radar_Processing.pde
├── Images/
│   └── circuit_diagram.png
└── README.md
```

These are suggested repository paths. The uploaded Arduino file is currently named `Radar_Arduino(1).ino`; you may rename it to `Radar_Arduino.ino` when placing it in the `Arduino` folder. The Processing sketch is `Radar_Processing.pde`. Processing sketches are commonly kept in a folder with the same name as the `.pde` file.

## Setup and Run

### 1. Wire the hardware

Wire the HC-SR04 and SG90 according to the pin tables above. Mount the ultrasonic sensor securely on the servo horn so the sensor rotates with the servo. Check the servo's mechanical movement before leaving it running.

### 2. Upload the Arduino sketch

1. Open `Radar_Arduino.ino` in Arduino IDE.
2. Connect the Arduino Uno to the computer over USB.
3. Select **Tools → Board → Arduino Uno**.
4. Select the correct entry under **Tools → Port**.
5. Verify/compile and upload the sketch.

### 3. Configure and run Processing

1. Open `Radar_Processing.pde` in Processing.
2. Confirm the Arduino's serial port. The current code uses `COM3`; edit the port string if needed.
3. Keep the baud rate at `9600` to match the Arduino sketch.
4. Close Arduino Serial Monitor if it is open.
5. Run the Processing sketch.

The Processing window is set to **1200 × 700** pixels. It draws the radar arcs, scan line, angle, distance, and an in-range/out-of-range label.

## Serial Data Protocol

The Arduino sends one record for each servo angle in this format:

```text
angle,distance.
```

Example:

```text
45,23.
```

- `angle`: commanded servo angle, in degrees.
- `distance`: calculated distance in centimetres, as an integer.
- `,`: separates the angle and distance.
- `.`: terminates the record; the Processing sketch uses `bufferUntil('.')`.
- Baud rate: **9600**.

The distance is calculated from the echo pulse duration using approximately:

```text
distance_cm = duration_microseconds × 0.034 / 2
```

If `pulseIn()` returns zero because no echo was received within 24,000 µs, the Arduino sends `400` as a sentinel value.

### Important Processing parser note

The Processing sketch calls `readStringUntil('.')`, splits the returned string at the comma, and converts the distance substring to an integer. Depending on how the serial library returns the delimiter, the distance substring may still contain the final period (for example, `"23."`). If the Processing console reports a number-format error or the display stops updating, remove the trailing period before converting the distance, for example:

```java
data = myPort.readStringUntil('.');
if (data != null) {
  data = trim(data);
  data = data.replace(".", "");
  index1 = data.indexOf(",");

  if (index1 > 0) {
    angle = data.substring(0, index1);
    distance = data.substring(index1 + 1);
    iAngle = int(angle);
    iDistance = int(distance);
  }
}
```

This is a parser robustness adjustment; the Arduino's intended protocol remains `angle,distance.`.

## How the Code Works

1. The Arduino sets D11 as an output and D9 as an input.
2. It starts serial communication at 9600 baud and attaches the servo to D12.
3. The first loop commands angles from 15° through 165° inclusive.
4. The second loop commands angles from 165° down to 16°. The next cycle starts again at 15°.
5. At each position, the sketch triggers the HC-SR04 and measures the echo pulse.
6. It prints the angle and distance followed by a period.
7. Each step aims to take at least approximately 33 ms, though sensor measurement time affects the actual interval.

The Processing sketch reads records until the period delimiter, updates the current angle and distance, and redraws the radar display. It marks a red object line when `iDistance < 40` and labels readings above 40 as `Out of Range`. At exactly 40 cm, the code labels the reading `In Range`, but does not draw the red object line or print the numeric distance because those checks use `< 40`.

## Troubleshooting

### Servo does not move

- Confirm the signal wire is connected to D12.
- Check servo power and ground.
- Ensure the servo supply ground is connected to Arduino GND.
- Make sure the servo horn is not blocked.

### Distance always shows `400`

- Check HC-SR04 VCC and GND.
- Confirm `TRIG` is on D11 and `ECHO` is on D9.
- Check sensor orientation and wiring.
- `400` is returned when no echo is received within the 24,000 µs timeout.

### Processing does not connect

- Confirm the Arduino is connected and the correct port is selected.
- Change the hard-coded `COM3` string in `Radar_Processing.pde` if the Arduino uses a different port.
- Close Arduino Serial Monitor before running Processing.
- Confirm both sketches use 9600 baud.

### Processing display does not update or reports a parsing error

- Confirm the Arduino is sending records in `angle,distance.` format.
- Check that the Processing sketch receives and removes the period delimiter before converting the distance text to an integer.
- Confirm the correct serial port is open.

### Serial Monitor shows unreadable characters

Set the Serial Monitor to **9600 baud**.

## Limitations and Safety

- Ultrasonic readings depend on the target's size, angle, surface, and environment.
- The value `400` indicates an echo timeout; it is not a verified maximum-range measurement.
- The servo is commanded between 15° and 165°. Actual movement depends on the servo and mounting.
- Keep fingers and wires clear of the moving servo horn.
- Disconnect power before changing wiring.
- A servo can draw current peaks; a suitable external supply can help prevent resets and unstable readings.

## License

No license is specified in the supplied source files. Add a license file if you want to define the terms under which others may use, modify, or redistribute the project.
