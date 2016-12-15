from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.scatter import ScatterPlane
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.uix.button import Button
from kivy.uix.scrollview import ScrollView
from kivy.uix.gridlayout import GridLayout
from kivy.graphics.instructions import InstructionGroup
from kivy.graphics import Color, Rectangle
from kivy.core.window import Window
from kivy.uix.relativelayout import RelativeLayout
from kivy.uix.popup import Popup

import matplotlib.cm as cmx
import matplotlib.colors as colors


from kivy.uix.codeinput import CodeInput
from pygments.lexers import CythonLexer

from visualize_duplicates import *

class MenuScreen(Screen):
    def __init__ (self, **kwargs):
        super (MenuScreen, self).__init__(**kwargs)

        # Set the variables for the class
        self.duplist = kwargs['duplist']
        self.dupfiles = kwargs['dupfiles']
        self.sm = kwargs['sm']

        # Create grid view
        layout = GridLayout(cols=1, padding=10, spacing=10, size_hint=(None, None), width=750)
        layout.bind(minimum_height=layout.setter('height'))

        # Add a button for each file that has duplicates (ordered)
        files = reversed(sorted(self.dupfiles, key=self.dupfiles.get))
        for dupfile in files:
            btn = Button(text="%s :  %d" %(dupfile, self.dupfiles[dupfile]), size=(750, 40), size_hint=(None, None))
            btn.bind(on_release=self.openDocView(dupfile))
            layout.add_widget(btn)

        # Adds a scroll view
        root = ScrollView(size_hint=(None, None), size=(750, 600), pos_hint={'center_x': .5, 'center_y': .5}, do_scroll_x=False)
        root.add_widget(layout)

        self.add_widget(root)

    # Returns function to open a doc view
    def openDocView(self, path):        
        def openView(obj):
            dupClasses = []
            dupFiles = {}

            # Creates a list with all the duplicate classes and a list with the files they are in
            for x in self.duplist:
                keys = x.getDups().keys()
                if path in keys:
                    dupClasses.append(x)
                    for y in keys:
                        if y not in dupFiles.keys():
                            with open(y) as f:
                                dupFiles[y] = len(f.readlines())

            self.sm.add_widget(DocView(name='docView', fileName=path, dupClasses=dupClasses, dupFiles=dupFiles, sm=self.sm))
            self.sm.current = 'docView'

        return openView


class DocView(Screen):
    def __init__ (self, **kwargs):
        super (DocView, self).__init__(**kwargs)

        #print dupFiles
        self.height_constant = 5.0
        self.sf = 1.0
        self.size = Window.size
        self.fileName = kwargs['fileName']  
        self.dupClasses = kwargs['dupClasses']
        self.dupFiles = kwargs['dupFiles']
        self.sm = kwargs['sm']    

        parent = Widget()

        # Fix the scaling of the document view
        screen_size = self.size
        max_height = self.dupFiles[max(self.dupFiles, key=self.dupFiles.get)] * self.height_constant * 1.4

        if len(self.dupFiles) * 220 + 200 > screen_size[0]:
            self.sf = (len(self.dupFiles) * 220 + 200) / float(screen_size[0])  

     
        if max_height > screen_size[1] and self.sf < max_height / float(screen_size[1]):
            self.sf = max_height / float(screen_size[1])

        # Creates the plane
        s = ScatterPlane(scale=1/self.sf, do_scale=True, do_rotation=False)
        parent.add_widget(s)

        # Adds a back button
        clearbtn = Button(text='Back')
        clearbtn.bind(on_release=self.back)
        parent.add_widget(clearbtn)

        # Adds the code blocks
        for index, x in enumerate(self.dupFiles):
            self.addBlock(s, self.dupFiles[x], self.dupClasses, x, index)


        self.add_widget(parent)

    def addBlock(self, view, loc, dupsClasses, path, index):
        height = loc * self.height_constant

        # Creates a color map for the number of duplicates
        norm  = colors.Normalize(vmin=0, vmax=len(dupsClasses))
        color_map = cmx.ScalarMappable(norm=norm, cmap='hsv') 

        # Creates a code block
        layout = RelativeLayout(size=(200, height + 20), pos=(0 + (220 * index), ((self.size[1] / 2.0) * self.sf - (height / 2.0))))
        with layout.canvas:
            Color(1., 1., 1.)
            Rectangle(pos=(0, 0), size=(200, height + 20))

        # Adds file name to code block
        l = Label(text=path.split("/")[-1], font_size='10sp', color=(0, 0, 0, 1), pos=(0,(height/2.0) + 5))
        layout.add_widget(l)

        # Adds a colored button for each duplicate in the file with the right size and posistion
        for i, dupClass in enumerate(dupsClasses):
            if path in dupClass.getDups():

                # Get the duplicates from the class and the color of the dup class
                duplicates = dupClass.getDups()[path]
                rgba = color_map.to_rgba(i)

                for dup in duplicates:
                    # Calculates the start, end, loc, pos and height of the duplicated
                    start, end = dup.getLoc()
                    dupLoc = (end - start + 1) * self.height_constant
                    dup_height = (dupLoc) / float(height + 20)
                    dup_pos = ((height) - (start * self.height_constant)) - dupLoc

                    # Creates colored button with the right size and pos in the code block
                    button = Button(text="%d-%d:%d" % (start, end, end - start + 1), size_hint=(1.0, dup_height), pos=(0, dup_pos), background_color=rgba)
                    button.bind(on_release= self.dupClicked(path, start, end))
                    layout.add_widget(button)

        # Adds the block to the view
        view.add_widget(layout)

    # Function to show the code when the dup is clicked
    def dupClicked(self, path, start, end):
        layout = RelativeLayout()

        # Reads the code from the start until the end of the dup
        code = ""
        fo = open(path, "r")
        lines = fo.readlines()

        for x in range(end-start + 1):
            code += lines[start + x -1]

        # Creates a codeView and a back button
        codeinput = CodeInput(lexer=CythonLexer(), text=code, readonly=False)
        button = Button(text="Close", size_hint=(0.3, 0.05), pos_hint={'right' : 1})


        layout.add_widget(codeinput)
        layout.add_widget(button)

        # Creates a popup with the code view
        popup = Popup(content=layout, auto_dismiss=False, title="Path: %s\nStart: %d, end: %d, size: %d"%(path, start, end, end - start + 1))
        button.bind(on_press=popup.dismiss)
        
        def openPopup(obj):
            popup.open()

        # Returns function to open the popup
        return openPopup

    # Function for the back button to go back
    def back(self, obj):
        self.sm.current = 'menu'
        self.sm.remove_widget(self.sm.get_screen('docView'))


class TestApp(App):

    def build(self):

        # Create the screen manager
        sm = ScreenManager()
        dupfiles, duplist = convertRascalToDups('TestProject/blader.tmp')
        sm.add_widget(MenuScreen(name='menu', dupfiles=dupfiles, duplist=duplist, sm=sm))

        return sm

if __name__ == '__main__':
    TestApp().run()