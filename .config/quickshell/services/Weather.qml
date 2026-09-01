pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property int temperature: 0
    property int weatherCode: 0
    property string icon: {
        switch (weatherCode) {
        case 1:
        case 2:
        case 3:
            return "🌤️";
            break;
        case 45:
        case 48:
            return "☁️";
            break;
        case 61:
        case 63:
        case 65:
            return "🌧️";
            break;
        case 80:
            return "☀️";
            break;
        default:
            return "...";
        }
    }

    Process {
        id: dataFetcher
        running: true
        command: ["curl", "-s", "https://api.open-meteo.com/v1/forecast?latitude=6.13&longitude=1.22&current_weather=true", "|", "jq"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                try {
                    const txt = this.text;
                    const parsedData = JSON.parse(txt);
                    root.temperature = parsedData.current_weather.temperature;
                    root.weatherCode = parsedData.current_weather.weathercode;
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        onTriggered: {
            dataFetcher.running = true;
        }
    }
}
