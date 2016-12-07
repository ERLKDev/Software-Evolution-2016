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

        self.duplist = duplist

        layout = GridLayout(cols=1, padding=10, spacing=10,
                size_hint=(None, None), width=750)

        layout.bind(minimum_height=layout.setter('height'))

        for dupfile in dupfiles:
            btn = Button(text=dupfile, size=(750, 40),
                         size_hint=(None, None))
            btn.bind(on_release=self.openDocView)
            layout.add_widget(btn)


        root = ScrollView(size_hint=(None, None), size=(750, 600),
                pos_hint={'center_x': .5, 'center_y': .5}, do_scroll_x=False)
        root.add_widget(layout)

        self.add_widget(root)

    def openDocView(self, obj):
        dupClasses = []
        dupFiles = []
        for x in self.duplist:
            keys = x.getDups().keys()
            if obj.text in keys:
                dupClasses.append(x)
                for y in keys:
                    if y not in dupFiles:
                        with open(y) as f:
                            dupFiles.append((y, len(f.readlines())))

        sm.add_widget(DocView(name='docView', file_name=obj.text, dupClasses=dupClasses, dupFiles=dupFiles))
        sm.current = 'docView'


class DocView(Screen):
    def __init__ (self, file_name, dupClasses, dupFiles, **kwargs):
        super (DocView, self).__init__(**kwargs)

        self.sf = 1.0
        self.size = Window.size
        self.file_name = file_name      

        parent = Widget()

        screen_size = self.size

        if len(files) * 220 + 200 > screen_size[1]:
            self.sf = (len(files) * 220 + 200) / float(screen_size[0])  

        s = ScatterPlane(scale=1/self.sf, do_scale=True, do_rotation=False)
        parent.add_widget(s)


        clearbtn = Button(text='Back')
        clearbtn.bind(on_release=self.back)
        parent.add_widget(clearbtn)

        index = 0
        for x in files:
            self.addBlock(s, x[1], [(140, 23), (30, 20)], x[0], index)
            index += 1
        self.add_widget(parent)

    def addBlock(self, view, loc, dups, path, index):
        height = loc

        norm  = colors.Normalize(vmin=0, vmax=len(dups))
        color_map = cmx.ScalarMappable(norm=norm, cmap='hsv') 

        layout = RelativeLayout(size=(200, height), pos=(0 + (220 * index), ((self.size[1] / 2.0) * self.sf - (height / 2.0))))
        with layout.canvas:
            Color(1., 1., 1.)
            Rectangle(pos=(0, 0), size=(200, height))


        l = Label(text=path, font_size='30sp', color=(0, 0, 0, 1), pos=(0,(height/2.0) - 10))
        layout.add_widget(l)

        i = 0
        for dup in dups:
            rgba = color_map.to_rgba(i)
            dup_height = dup[1] / float(loc) 
            dup_pos = (loc - dup[0]) - dup[1]
            button = Button(size_hint=(1, dup_height), pos=(0, dup_pos), background_color=rgba)
            button.bind(on_release= lambda x: self.dupClicked(("foo.js", 2, 5), x))
            layout.add_widget(button)
            i += 1

        # Here, view should be a Widget or subclass
        view.add_widget(layout)

    def dupClicked(self, (path, start, end), obj):
        layout = RelativeLayout()

        code = ""
        fo = open(path, "r")
        lines = fo.readlines()
        for x in range(end-start):
            code += lines[start + x]

        codeinput = CodeInput(lexer=CythonLexer(), text=code, readonly=True)
        button = Button(text="Close", size_hint=(1, 0.05))
        layout.add_widget(codeinput)
        layout.add_widget(button)
        popup = Popup(content=layout, auto_dismiss=False)
        button.bind(on_press=popup.dismiss)
        popup.open()

    def back(self, obj):
        sm.current = 'menu'
        sm.remove_widget(sm.get_screen('docView'))


# Create the screen manager
sm = ScreenManager()
dupfiles, duplist = convertRascalToDups('TestProject/blader.tmp')
sm.add_widget(MenuScreen(name='menu', dupfiles=dupfiles, duplist=duplist))

class TestApp(App):

    def build(self):
        return sm

if __name__ == '__main__':
    TestApp().run()

