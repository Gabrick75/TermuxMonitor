# TermuxMonitor
The code has the function to retrieve data from the device and subsequently transmit it via the CallMeBot API to the Whatsapp plataform

## System Monitoring on Termux - Send Data to WhatsApp
Alert! this code works best with sudo superuser (ROOT)<br>
This project aims to create a simple solution for system resource monitoring on Termux (a terminal environment for Android). The program collects information about Battery, CPU usage, RAM, ROM, network and swap usage, and sends this data using CallMeBot API to a WhatsApp number.
Features

## Features:
- **Battery Status**
- **CPU Usage**
- **RAM Usage**
- **Storage (ROM)**
- **Network Data**
- **Swap**

These statistics are collected periodically on an hourly basis and automatically sent to a WhatsApp number, allowing you to track your system's performance at any time.

## Dependencies:
- **Figlet**
- **jq**
- **Curl**
- **Ping**
- **Termux-api**

## Running the script:
Clone this repository and run the script using the following command:

```bash
git clone https://github.com/Gabrick75/TermuxMonitor
cd TermuxMonitor
chmod +x Monitor.sh
./Monitor.sh
```
