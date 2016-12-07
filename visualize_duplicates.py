import re
from random import randint

row_reg = r"\((?:[0-9]*,[0-9]*,)<([0-9]*),(?:[0-9]*)>,<([0-9]*),(?:[0-9]*)>\)"


class Location():
    def __init__(self, rascal_location):
        self.start, self.end = self.convert_rascal_location(rascal_location)

    def convert_rascal_location(self, rascal_location):
        matches = re.finditer(row_reg, rascal_location)
        for match in matches:
             start = match.group(1)
             end = match.group(2)
        return (start,end)

    def get_loc(self):
        return (self.start, self.end)

    def __str__(self):
        return "Start: {0}, End: {1}".format(self.start, self.end)

    def __repr__(self):
        return "(Start: {0}; End: {1})".format(self.start, self.end)


class DuplicateClass():

    def __init__(self):
        self.duplicates = {}
        return

    def add_duplicate(self, path, duplicate_loc):
        loc = Location(duplicate_loc)

        if path in self.duplicates.keys():
            self.duplicates[path] = self.duplicates[path] + [loc]
        else:
            self.duplicates[path] = [loc]

    def get_dups(self):
        return self.duplicates        
    def __str__(self):
        str_format = ""
        for k in self.duplicates.keys():
            str_format += "{0} {1}\n".format(k, self.duplicates[k])

        return str_format

if __name__ == '__main__':
    f = open('TestProject/blader.tmp', 'r')
    regex = r"\|(\w*\+\w*)(?:\:\/\/\/|\/\))([\w(-|_)\/]*)\|(\([0-9]*,[0-9]*,<[0-9]*,[0-9]*>,<[0-9]*,[0-9]*>\))"
    duplist = []
    for p in f.readlines():
        dups = DuplicateClass()
        matches = re.finditer(regex, p)
        for match in matches:
            path = match.group(2)
            rascal_location = match.group(3)
            dups.add_duplicate(path, rascal_location)
        duplist.append(dups)
    for dup in duplist:
        print dup
