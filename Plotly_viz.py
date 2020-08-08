#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug  3 22:19:27 2020

@author: theari527
"""

##################
# Adam Imran     #
# ANLY 503 HW 6  #
##################

# AI: Import packages
import pandas as pd
import plotly.express as px
import plotly.graph_objs as go

# AI: Figure 1: Bar plot of Atomic Index 0
#####################################################################
scalar = pd.read_csv("scalar_coupling_contributions.csv")
index0 = scalar.atom_index_0.value_counts()
index0_Frame = index0.to_frame()
index0_Frame = index0_Frame.reset_index()
index0_Frame = index0_Frame.rename(columns={"index": "atom_index_0", "atom_index_0": "Counts"})
print(index0_Frame)
fig = px.bar(index0_Frame, x='atom_index_0', y='Counts',labels={
                     "atom_index_0": "Atomic Index 0",
                     "Counts": "Counts"
                 },
                title="Barplot of Atomic Index 0")
fig.write_html("atomic_index0.html")
#####################################################################

# AI: Figure 2: Histogram plot of Atomic Index 1
#####################################################################
fig = px.histogram(scalar, x="atom_index_1", labels={
                     "atom_index_1": "Atomic Index 1"
                 },
                title="Histogram of Atomic Index 1")
fig.write_html("atomic_index1.html")
#####################################################################

# AI: Figure 3a: Pie plot of Types
#####################################################################
colors = ['gold', 'mediumturquoise', 'darkorange', 'lightgreen','lightblue','red','yellow']

type1 = scalar.type.value_counts()
type1_Frame = type1.to_frame()
type1_Frame = type1_Frame.reset_index()
type1_Frame = type1_Frame.rename(columns={"index": "type", "type": "Counts"})

fig = go.Figure(data=[go.Pie(labels=list(type1_Frame.type),
                             values=list(type1_Frame.Counts))])
fig.update_traces(hoverinfo='label+percent', textinfo='value', textfont_size=20,
                  marker=dict(colors=colors, line=dict(color='#000000', width=2)))
fig.write_html("types.html")
#####################################################################

# AI: Figure 3b: Pie plot of Types Subset JHC
#####################################################################
JHC = scalar.loc[scalar['type'].isin(['1JHC','2JHC','3JHC'])]
JHC_thinned = JHC.sample(200)
JHC_thinned = JHC_thinned[JHC_thinned.sd <= 0.9]

type1_thinned = JHC_thinned.type.value_counts()
type1_thinned_Frame = type1_thinned.to_frame()
type1_thinned_Frame = type1_thinned_Frame.reset_index()
type1_thinned_Frame = type1_thinned_Frame.rename(columns={"index": "type", "type": "Counts"})

fig = go.Figure(data=[go.Pie(labels=list(type1_thinned_Frame.type), 
                             values=list(type1_thinned_Frame.Counts), hole=.3)])
fig.write_html("type_subset.html")
#####################################################################

# AI: Figure 4: Scatter plot of fc and sd
#####################################################################
fig = px.scatter(JHC_thinned, x="fc", y="sd", trendline="ols", labels={
                     "fc": "Fermi Constant", 
                     "sd": "Spin Dipole"
                 },
                title="Fermi Constant vs. Spin Dipole Constant")
fig.write_html("fermiVSspin.html")
#####################################################################

# AI: Figure 5: Scatterplot of dso and pso lowess smooth
#####################################################################
fig = px.scatter(JHC_thinned, x="dso", y="pso", color="type", trendline="lowess", labels={
                     "dso": "Diamegnetic Spin", 
                     "pso": "Paramagnetic Spin"
                 },
                title="Magnetic Spins")
fig.write_html("magnetic.html")
#####################################################################

# Figure 6a: Fermi violin
#####################################################################
fig = px.violin(JHC_thinned, y="fc", x="type", color="type", box=True,
          hover_data=JHC_thinned.columns, labels={
                     "fc": "Fermi Constant", 
                 },
                title="Fermi Constant by Type")
fig.write_html("fermi.html")
#####################################################################

# Figure 6b: Spin violin
#####################################################################
fig = px.violin(JHC_thinned, y="sd", x="type", color="type", box=True,
          hover_data=JHC_thinned.columns, labels={
                     "sd": "Spin-Dipole", 
                 },
                title="Spin Dipole by Type")
fig.write_html("spin.html")
#####################################################################

# Figure 6c: Paramagnetic violin
#####################################################################
fig = px.violin(JHC_thinned, y="pso", x="type", color="type", box=True,
          hover_data=JHC_thinned.columns, labels={
                     "pso": "Para-Magnetic Constant", 
                 },
                title="Para-Magnetic value by Type")
fig.write_html("Paramagnetic.html")
#####################################################################

# Figure 6d: Diamagnetic violin
#####################################################################
fig = px.violin(JHC_thinned, y="dso", x="type", color="type", box=True,
          hover_data=JHC_thinned.columns, labels={
                     "dso": "Dia-Magnetic Constant", 
                 },
                title="Dia-Magnetic value by Type")
fig.write_html("Diamagnetic.html")
#####################################################################
