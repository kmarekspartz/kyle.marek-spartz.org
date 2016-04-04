---
title: Setting WTForms Selection Fields Dynamically
tags: python, web-dev, open-source
description: Setting WTForms selection fields dynamically
---

[WTForms](http://wtforms.readthedocs.org/en/latest/) is a very useful tool for constructing web forms and operating on their data.

Setting selection fields dynamically from database content is not directly apparent, but they do provide [one recipe](http://wtforms.readthedocs.org/en/latest/specific_problems.html#dynamic-form-composition) to accomplish such functionality. I don't mind this approach, but there are a few other options.

One approach that I've used is to provide a `set_choices` method:

~~~ python
class MyForm(Form):
    selection_field = SelectField()

    def set_choices(self):
        from models import Model
        self.selection_field.choices = query(Model).all()
~~~

You'd have to call the set_choices method after instantiating your form. This gives you some flexibility, but some redundant code.

Another option is to do this work in the `__init__`:

~~~ python
class MyForm(Form):
    ...
    def __init__(self):
        super(MyForm, self).__init__()

        from models import Model
        self.selection_field.choices = query(Model).all()
~~~

This allows you to use the filtered form without changing your external code.

Another approach would be to pass in the choices as a parameter to `__init__`:

~~~ python
class MyForm(Form):
    ...
    def __init__(self, selection_choices):
        super(MyForm, self).__init__()
        self.selection_field.choices = selection_choices
~~~
