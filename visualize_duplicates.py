class Location():
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def __str__(self):
        return "Start: {0}, End: {1}".format(self.start, self.end)

class Duplicate():
    duplicates = []
    def __init__(self, location):
        self.location = location
        return

    def add_duplicate(duplicate_loc):
        duplicates.add(duplicate_loc)

    def __str__(self):
        str_format = "Duplicate at {0}.\n Clones at: {1}".format(self.location, self.duplicates)
        return str_format

if __name__ == '__main__':
    a = Duplicate(Location(0,1))
    print a
