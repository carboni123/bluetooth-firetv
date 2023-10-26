#!/bin/bash -e

USER=pi
# Read the Bluetooth device's MAC address from file.txt
DEVICE_MAC_ADDRESS=$(cat /home/$USER/Desktop/AmazonFireTVRemoteMAC.txt)
#DEVICE_MAC_ADDRESS='XX:XX:XX:XX:XX:XX'

# Remove the paired Bluetooth device using bluetoothctl
echo -e "remove $DEVICE_MAC_ADDRESS\nquit" | bluetoothctl

while true; do
    # Run a Bluetooth scan to find nearby devices
    (echo -e "scan on"; sleep 5; echo -e "scan off") | bluetoothctl

    # Get the list of devices found during the scan
    devices=$(echo -e "devices\nquit" | bluetoothctl | grep "Device" | awk '{print $2}')

    # Check if the desired device is found in the scan results
    if echo "$devices" | grep -q "$DEVICE_MAC_ADDRESS"; then

        # Attempt to connect to the device
        (echo -e "connect $DEVICE_MAC_ADDRESS"; sleep 5; echo -e "quit") | bluetoothctl

        # Check the connection status
        connected_device=$(echo -e "info $DEVICE_MAC_ADDRESS\nquit" | bluetoothctl | grep "Connected" | awk '{print $2}')
        
        if [ "$connected_device" == "yes" ]; then
            echo "Connected to the device successfully!"
            exit 1
        else
            echo "Failed to connect. Retrying..."
        fi
    else
        echo "Device not found. Scanning again in 3 seconds..."
        sleep 3
    fi
done

