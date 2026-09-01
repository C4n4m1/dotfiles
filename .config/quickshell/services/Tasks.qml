pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var tasksList: JSON.parse(cachedTasks.text())
    property var tasksListCached: []

    Timer {
        id: refresh
        running: true
        repeat: true
        interval: 180000
        onTriggered: {
            taskFetcher.running = true;
        }
    }

    Component.onCompleted: {
        taskFetcher.running = true;  // ← fetch immediately on load
    }

    Process {
        id: taskFetcher
        command: ["/home/credo/.config/quickshell/services/scripts/taskFetch.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                try {
                    const txt = text;
                    const parsedData = JSON.parse(txt);
                    var tasks = parsedData.map(task => ({
                                id: task.id,
                                label: task.content,
                                priority: task.priority,
                                description: task.description,
                                due: task.due,
                                deadline: task.deadline
                            }));
                    root.tasksListCached = tasks;
                    // console.log("TASKS :::: task.json updated !");
                    cachedTasks.setText(JSON.stringify(tasks));
                } catch (e) {
                    console.error(`[TasksService] ${e.message}`);
                }
            }
        }
    }

    Process {
        id: taskValidator
        command: ["/home/credo/.config/quickshell/services/scripts/taskValidate.sh"]
        running: false
    }

    FileView {
        id: cachedTasks
        path: "/home/credo/.config/quickshell/services/cache/tasks.json"
        watchChanges: true

        onFileChanged: () => {
            reload();
        }
    }

    function validateTask(taskID) {
        taskValidator.exec(["/home/credo/.config/quickshell/services/scripts/taskValidate.sh", taskID]);
        taskFetcher.running = true;
    }
}
