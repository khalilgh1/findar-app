from django.contrib import admin
from .models import *

# Register your models here.
admin.site.register(CustomUser)
admin.site.register(Post)
admin.site.register(Photos)
admin.site.register(SavedPosts)
admin.site.register(Report)
admin.site.register(BoostingPlan)
admin.site.register(Boosting)