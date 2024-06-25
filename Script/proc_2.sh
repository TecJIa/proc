#!/bin/bash



proc_uptime=`cat /proc/uptime | awk -F" " '{print $1}'`

clk_tck=`getconf CLK_TCK`                                     # получаеv количество тактов в секунду. используется для вычисления общего 

							      # времени выполнения процесса, деленного на количество тактов в секунду.

(echo "PID|TTY|STAT|TIME|COMMAND"                             # Формируем заголовок. В скобочках, потому что так красиво делается.

for dir in /proc/[0-9]*; do                                   # пробегаемся по всем директориям с именем в виде числа (пиды)

    if [ -d "$dir" ]; then                                    # Если это каталог

        pid=$(basename $dir)                                  # Pid = берем только имя каталога, удаляя путь

        cmd=$(cat $dir/cmdline | tr -d '\0' | awk '{print $1}' | tr -d ' ') # Считываем содержимое файла | удаляем нулевые байты | берем имя (первый аргумент) | удаляем пробелы

        if [ -n "$cmd" ]; then                                # проверяем, не пустой ли cmd

            cmd=$(basename $cmd 2>/dev/null)

        else

            cmd="-"

        fi

        stat=$(</proc/$pid/stat)

        state=$(echo "$stat" | awk -F" " '{print $3}')

        tty=$(echo "$stat" | awk -F" " '{print $7}')



        utime=`echo "$stat" | awk -F" " '{print $14}'`        # Вычисляем пользовательское время процесса

        stime=`echo "$stat" | awk -F" " '{print $15}'`        # Вычисляем системное время процесса

        ttime=$((utime + stime))

        time=$((ttime / clk_tck))

        if [ "$cmd" != "-" ]; then

            echo "${pid}|${tty}|${state}|${time}|${cmd}" 2>/dev/null

        else 

            :

        fi

    fi

done ) | column -t -s "|"



