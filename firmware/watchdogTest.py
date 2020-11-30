import pandas as pd
import time
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler

def on_moved(event):
    # print(f"ok ok ok, someone moved {event.src_path} to {event.dest_path}")
    orig = event.dest_path
    print(f"{orig} has been modified")
    df = pd.read_csv(orig)
    print("------------- MINTS LATEST -------------:")
    df['dateTime'] = pd.to_datetime(df['dateTime'])
    print(df[-10:])

if __name__ == "__main__":

    # With patterns="*.csv" you should not have to add ignore_patterns=["*~"
    patterns = [\
            "*/001e06305a12/*/*/*/*.csv*",\
            "*/001e06323a12/*/*/*/*.csv*",\
            "*/001e06318cd1/*/*/*/*.csv*",\
            "*/001e06305a61/*/*/*/*.csv*",\
            "*/001e06323a05/*/*/*/*.csv*",\
            "*/001e06305a57/*/*/*/*.csv*",\
            "*/001e063059c2/*/*/*/*.csv*",\
            "*/001e06318c28/*/*/*/*.csv*",\
            "*/001e06305a6b/*/*/*/*.csv*",\
            "*/001e063239e3/*/*/*/*.csv*",\
            "*/001e06305a6c/*/*/*/*.csv*",\
            "*/001e063239e6/*/*/*/*.csv*",\
            "*/001e06305a0a/*/*/*/*.csv*",\
            "*/001e06318cee/*/*/*/*.csv*",\
            "*/001e06318cf1/*/*/*/*.csv*",\
            "*/001e063059c1/*/*/*/*.csv*"\
            ]

    ignore_patterns =["/2019/","/2018/","/2018/","/2016/"]
    ignore_directories = False
    case_sensitive = True
    my_event_handler = PatternMatchingEventHandler(patterns, ignore_patterns, ignore_directories, case_sensitive)

    my_event_handler.on_moved = on_moved
    path = "/media/teamlary/teamlary3/air930/mintsData/raw/"
    go_recursively = True
    my_observer = Observer()
    my_observer.schedule(my_event_handler, path, recursive=go_recursively)
    my_observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        my_observer.stop()
        my_observer.join()