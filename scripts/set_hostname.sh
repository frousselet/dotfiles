scutil --set HostName FRO-$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')