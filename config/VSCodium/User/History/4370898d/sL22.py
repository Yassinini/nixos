import cv2 as cv
import numpy as np

vid_path = "/home/suupatruupa/Downloads/WhatsApp Video 2026-08-20 at 22.33.30.mp4"
vid = cv.VideoCapture(vid_path)
fps = vid.get(cv.CAP_PROP_FPS)
framenum =0
inframe = []
lower_lim = np.array([0, 0, 200])
upper_lim = np.array([180, 40, 255])
kernel = np.ones((3, 3), np.uint8)

data = [] 

while True:
    ok, frame = vid.read()
    if not ok:
        break
    time = framenum/fps
    framenum+=1


    smol = cv.resize(frame, (1200, 800))
    grey = cv.cvtColor(smol, cv.COLOR_BGR2GRAY)
    _, mask = cv.threshold(grey, 200, 255, cv.THRESH_BINARY)
    mask = cv.erode(mask, kernel, iterations=7)
    mask = cv.dilate(mask, kernel, iterations=7)
    y, x = np.where(mask == 255)

    if len(x) > 0:
        cx = np.mean(x)
        cy = np.mean(y)

        inframe.append(framenum)
        x_min, x_max = x.min(), x.max()
        y_min, y_max = y.min(), y.max()
        # normal frame
        cv.rectangle(smol, (x_min, y_min), (x_max, y_max), (255,255,255), 2)
        cv.circle(smol, (int(cx), int(cy)), 2, (255,255,255), 1)
        cv.putText(smol, str(framenum), (100, 80), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        # mask frame
        cv.rectangle(mask, (x_min, y_min), (x_max, y_max), (255,255,255), 2)
        cv.circle(mask, (int(cx), int(cy)), 2, (255,255,255), 1)
        cv.putText(mask, str(framenum), (100, 80), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        data.append({"time": time, "cx": cx, "cy": cy})

    cv.imshow("frame", smol)
    cv.imshow("mask", mask)

    if cv.waitKey(50) & 0xFF == 27:
        break

time_sec = framenum / fps
print(f"last frame: {framenum}")
print(f"fps: {fps}")
print(f"time: {time_sec}")
print(f"\n frames with object inframe: {inframe}")
print(f"number of FWOIF: {len(inframe)}")
print(f"number of unused frames: {framenum - len(inframe)}")

vid.release()
cv.destroyAllWindows()

## TODO insert time,x,y into csv file
import pandas as pd

d = pd.DataFrame(data)
d.to_csv("trajectory_data.csv", index=False)