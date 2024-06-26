import pyglet
import math
from random import randint
from pyglet import shapes
import numpy as np
import time

window = pyglet.window.Window()
batch = pyglet.graphics.Batch()

window.height = 700
window.width = 1200
dt = 1 / 30


class hydrogen:
    def __init__(self):
        self.color = (randint(0, 254), randint(0, 254), randint(0, 254))
        self.x = randint(0, window.width)
        self.y = randint(0, window.height)
        self.mass = randint(2, 5)
        self.radius = self.mass * 1.25
        self.pull_radius = 10
        self.velocityX = 10  # 1 * randint(-2, 2)
        self.velocityY = 10  # 1 * randint(-2, 2)
        self.generate = shapes.Circle(
            x=self.x, y=self.y, radius=self.radius, color=self.color, batch=batch
        )

    def direction(self):
        normCoef = 0
        if self.velocityX == 0 and self.velocityY == 0:
            normCoef = 0
        else:
            normCoef = 1 / math.sqrt(
                self.velocityX * self.velocityX + self.velocityY * self.velocityY
            )
        return (self.velocityX * normCoef, self.velocityY * normCoef)


def get_response_velocities(a, b):
    respAX = ((a.mass - b.mass) * a.velocityX + (2 * b.mass * b.velocityX)) / (
        a.mass + b.mass
    )
    respAY = ((a.mass - b.mass) * a.velocityY + (2 * b.mass * b.velocityY)) / (
        a.mass + b.mass
    )
    respBX = ((b.mass - a.mass) * b.velocityX + (2 * a.mass * a.velocityX)) / (
        a.mass + b.mass
    )
    respBY = ((b.mass - a.mass) * b.velocityY + (2 * a.mass * a.velocityY)) / (
        a.mass + b.mass
    )

    return [respAX, respAY], [respBX, respBY]


def collisionCheck(a, b):
    distance = math.sqrt(
        (a.generate.x - b.generate.x) ** 2 + (a.generate.y - b.generate.y) ** 2
    )
    if distance <= (a.radius + b.radius):
        va, vb = get_response_velocities(a, b)
        # print(" collision" ,distance,a.generate.x ,b.generate.x,a.color,b.color)
        a.velocityX = va[0]
        a.velocityY = va[1]
        b.velocityX = vb[0]
        b.velocityY = vb[1]
        a.generate.x += a.velocityX
        a.generate.y += a.velocityY
        b.generate.x += b.velocityX
        b.generate.y += b.velocityY


def gasCloud():
    b = randint(0, window.height - 1)
    a = (window.height - b - b) / (window.width - 0)
    return (
        shapes.Line(
            0,
            b,
            window.width,
            window.height - b,
            2,
            color=(250, 30, 30),
            batch=batch,
        ),
        a,
        b,
    )


line, a, b = gasCloud()  # y = ax +b
atoms = []

sign = -1
n = 100
chunk = (line.x2 - line.x - 800) / n
for i in range(n):
    sign = -sign
    margin = randint(-50, 50)
    temp = hydrogen()
    x = chunk * i + 400
    y = a * x + b + ((n / 2) - abs((n / 2) - i)) * sign + margin

    temp.x = min(window.width, x)
    temp.y = min(window.height, y)
    temp.generate.x = min(window.width, x)
    temp.generate.y = min(window.height, y)
    if not (temp.x == window.width or temp.y == window.height):
        atoms.append(temp)


debounce = time.time()
debounce2 = time.time()
@window.event
def on_draw(): 
    window.clear()
    global debounce,debounce2,a
    b = time.time()
    dt = b - debounce
    debounce = b
    if time.time() -debounce2 >0.5 : 
        print("fps : "+str(round(1 / (dt))),end='\r') 
        debounce2 = time.time()



    for atom in atoms:
        batch.draw()
        dir = atom.direction()
        nextStepX = atom.generate.x + atom.radius * dir[0]
        nextStepY = atom.generate.y + atom.radius * dir[1]
        if not (nextStepX >= 0 and nextStepX <= window.width):
            atom.velocityX *= -1
        if not (nextStepY >= 0 and nextStepY <= window.height):
            atom.velocityY *= -1
        for neighbor in atoms:
           if neighbor is atom:
               continue
           collisionCheck(neighbor, atom)

        atom.generate.x += atom.velocityX
        atom.generate.y += atom.velocityY


pyglet.app.run()
