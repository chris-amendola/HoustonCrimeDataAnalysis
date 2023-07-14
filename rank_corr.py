# -*- coding: utf-8 -*-
"""
Created on Tue Jul  4 09:13:11 2023

@author: chris
"""
import numpy as np
from scipy import stats

prep=ovr_piv

prep['median_inc']=np.array([62042,36087,114144,56141,91888,49313,94917,54879,49925,37155,600130])

## Does median income correlate with crime counts in 2023
res=stats.spearmanr(prep['median_inc'],prep[2023])

res

## Does median income correlate with crime counts in 2022
res=stats.spearmanr(prep['median_inc'],prep[2022])

res

## Does median income correlate with crime changes between 2022 and 2023
res=stats.spearmanr(prep['median_inc'],prep['diff'])

res

""" Median income data by COH Council Districts was harvested from https://www.houstontx.gov/planning/Demographics/ '2024 Council District Profiles (2021 Demographics)'. 

Using Speamans' Rank Correlation test, median incomes were negatively correlated to Violent Crime Incident Counts in both 2022(pvalue=0.01) and 2023(pvalue=0.02). Correlations according to Cohen* were both 'large' - 2022: -0.77 and 2023: -0.68.

*Cohen J. (1988). Statistical Power Analysis for the Behavioral Sciences. New York, NY: Routledge Academic [Google Scholar] """

res=stats.spearmanr(prep[2022],prep['diff'])

res
