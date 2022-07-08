# -*- coding: utf-8 -*-
"""
Created on Mon Jul  4 16:05:06 2022

@author: jrbal
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statistics import stdev


scottie_games = pd.read_csv('scottie_barnes_game_log.txt', index_col = 0)

category_list = ['FG', 'FGA', '3P', '3PA', 'FT', 'FTA', 'ORB',
'DRB', 'TRB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']


#Hand-Crafted Mean Function
def mean(x):
    average = sum(x)/len(x)
    return average

#My Z-Score function
def zscore(x):
    xbar = mean(x)
    xtest = x[-1]
    if stdev(x) != 0:
        z = (xtest - xbar)/stdev(x)
    else:
        z = xtest - xbar
    return z
        
#This allows me to make the relatiev game scores by individual category        
def relative_game_score_by_category(category_name):
    score_list = []
    game_zscores = []
    i = 0
    category = scottie_games[category_name]
    for game in category:
        if game.isdigit():
            score_list += [int(game)]
            if i == 0:
                game_zscores += [0]
                i += 1
            else:
                game_z = zscore(score_list)
                game_zscores += [game_z]
    return game_zscores

#This calculates relative game scores for every category
def relative_game_scores():
    relative_game_scores_dict = dict()
    for category_name in category_list:
        score_list = []
        game_zscores = []
        i = 0
        category = scottie_games[category_name]
        for game in category:
            if game.isdigit():
                score_list += [int(game)]
                if i == 0:
                    game_zscores += [0]
                    i += 1
                else:
                    game_z = zscore(score_list)
                    game_zscores += [game_z]
        relative_game_scores_dict[category_name] = game_zscores
        rgsdf = pd.DataFrame(relative_game_scores_dict)
    game_labels = []
    for i in range(len(rgsdf)):
        game_labels += ['Game ' + str(i+1)]
    rgsdf.index = game_labels
    return rgsdf
    

#This makes my plots used in the article
def make_plots():
    rgsdf = relative_game_scores()
    rgsdf['TOV'] = rgsdf['TOV'] * -1
    rgsdf['PF'] = rgsdf['PF'] * -1
    combined_z_scores = rgsdf.sum(axis=1)
    avg_z_score = rgsdf.mean(axis = 1)
    plt.plot(combined_z_scores)
    plt.xlabel('Game')
    plt.ylabel('TRGS')
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    plt.xticks([0, 19, 39, 59, 73])
    plt.show()
    plt.clf()
    plt.plot(avg_z_score)
    plt.xlabel('Game')
    plt.ylabel('ARGS')
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    plt.xticks([0, 19, 39, 59, 73])
    plt.show()
    plt.clf()
    



            
    
    


        