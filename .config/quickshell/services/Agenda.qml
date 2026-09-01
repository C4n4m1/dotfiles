pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var eventsList: {
        const now = new Date();
        return JSON.parse(cachedEvents.data()).filter(event => (new Date(event.end) > now));
    }
    property var eventsListCached: []

    Timer {
        id: refresh
        running: true
        repeat: true
        interval: 180000
        onTriggered: {
            eventFetcher.running = true;
        }
    }

    Timer {
        id: refreshCache
        running: true
        repeat: true
        interval: 180000
        onTriggered: {
            const now = new Date();
            root.eventsList = JSON.parse(cachedEvents.data()).filter(event => (new Date(event.end) > now));
        }
    }

    Process {
        id: eventFetcher
        command: ["/home/credo/.config/quickshell/services/scripts/eventFetch.sh"]
        running: false

        onRunningChanged: {
            console.log("[TaskFetcher] running changed to:", running, "| exitCode:", exitCode);
        }

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[TaskFetcher] stream finished, text length:", text.length);
                if (text.length === 0)
                    return;
                try {
                    const txt = this.text;
                    const parsedData = JSON.parse(txt);
                    var events = [];
                    for (var i = 0; i < parsedData.length; i++) {
                        var calendar = parsedData[i];
                        var eventsList = calendar.items;
                        var eventsList = eventsList.map(item => ({
                                    agenda: calendar.summary,
                                    label: item.summary,
                                    start: item.start.dateTime,
                                    end: item.end.dateTime
                                }));
                        for (var j = 0; j < eventsList.length; j++) {
                            var event = eventsList[j];
                            events.push(event);
                        }
                    }
                    events.sort((a, b) => new Date(a.start) - new Date(b.start));
                    cachedEvents.setText(JSON.stringify(events));
                } catch (e) {
                    console.error(`[EventsService] ${e.message}`);
                }
            }
        }
    }

    FileView {
        id: cachedEvents
        path: "/home/credo/.config/quickshell/services/cache/events.json"
        watchChanges: true

        onFileChanged: () => {
            reload();
        }
    }
}
