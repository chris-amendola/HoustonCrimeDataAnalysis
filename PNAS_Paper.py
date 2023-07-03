# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 15:31:52 2023

@author: chris
"""
import pandas as pd

data_src='C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/124923-V1/'

show=pd.read_stata(f'''{data_src}detailed_category.dta''')
show.info()