class Location():
    def __init__(self, rascal_location):
        self.src, self.start, self.end = convert_rascal_location(rascal_location)

    def convert_rascal_location(rascal_location):
        pass
    def __str__(self):
        return "<{0}> => Start: {1}, End: {2}".format(self.src, self.start, self.end)

class Duplicate():
    duplicates = []
    def __init__(self, location):
        self.location = location
        return

    def add_duplicate(duplicate_loc):
        duplicates.add(duplicate_loc)

    def __str__(self):
        str_format = """~~~~~~~~~~~~~~~~~~~~~~~~v
Original at {0}.
Clones at: {1}
~~~~~~~~~~~~~~~~~~~~~~~~^""".format(self.location, self.duplicates)
        return str_format

if __name__ == '__main__':
    f = open('TestProject/blader.tmp', 'r')
    for p in f.readlines():
        print(p)

    #REGEX
    #(?:\|\w*\+\w*):\/*[\w*(-|_)\/]*\| [\(\[0-9]*,[0-9]*,<[0-9]*,[0-9]*>,<[0-9]*,[0-9]*>\)]*

    # a = Duplicate("")
    # print a
