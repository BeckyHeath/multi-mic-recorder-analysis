from harkpython import harkbasenode
#import pylab
import math
import json
import numpy as np
import os

#pylab.ion()


def Rect2Polar(x):
    R = math.sqrt(x[0] ** 2 + x[1] ** 2 + x[2] ** 2)
    Theta = math.atan2(x[2], (math.sqrt(x[0] ** 2 + x[1] ** 2)))
    Phi = math.atan2(x[1], x[0])
    return [R, Theta, Phi]


class HarkNode(harkbasenode.HarkBaseNode):
    def __init__(self):
        self.outputNames = ("OUTPUT",)
        self.outputTypes = ("prim_int",)
        self.SepFile = open("separated.csv", "w")
        self.SepFile.write("\t".join(["Time", "Sep", "R", "Theta", "Phi"]) + "\n")
        self.SpecFile = open("spectrum.txt", "w")

        f = open("parameter.json")
        Parameter = json.load(f)
        self.PERIOD = int(Parameter["PERIOD"][1])

    def calculate(self):
        if not (self.count % self.PERIOD):
            tmp = eval(self.TRACKING)
            if tmp["DATA"]:
                print(tmp["DATA"])
                for d in tmp["DATA"].items():
                    print(d)
                    Coordinates = map(str, Rect2Polar(d[1]["x"]))
                    self.SepFile.write(str(self.count) + "\t" + str(d[0]) + "\t" + "\t".join(Coordinates) + "\n")


            self.SPECTRUM = list(self.SPECTRUM[len(self.SPECTRUM)//2:])+list(self.SPECTRUM[:len(self.SPECTRUM)//2])
            Spectrum = map(str, self.SPECTRUM)
            self.SpecFile.write("\t".join(Spectrum) + "\n")
            print(self.count)
            print("average spectrum: {}".format(np.average(self.SPECTRUM)))

        self.outputValues["OUTPUT"] = 1
