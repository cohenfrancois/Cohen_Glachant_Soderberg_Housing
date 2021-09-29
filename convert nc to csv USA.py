# -*- coding: utf-8 -*-
"""
Created on Tue May 18 16:59:41 2021

@author: Francois
"""

#!/usr/bin/python3
 
import netCDF4
from netCDF4 import num2date
import numpy as np
import os
import pandas as pd

##for counter in range(1,n+1):

for period in range(1979, 2014):

    f = netCDF4.Dataset('C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\cropped_tmax_' + str(period) + '.nc')
    # Extract variable
    tmax = f.variables['tmax']
 
    # Get dimensions assuming 3D: time, latitude, longitude
    time_dim, lat_dim, lon_dim = tmax.get_dims()
    time_var = f.variables[time_dim.name]
    times = num2date(time_var[:], time_var.units)
    latitudes = f.variables[lat_dim.name][:]
    longitudes = f.variables[lon_dim.name][:]
 
    output_dir = 'C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\\' 
 
    # =====================================================================
    # Write data as a table with 4 columns: time, latitude, longitude, value
    # =====================================================================
    filename = os.path.join(output_dir, 'tmax_' + str(period) + '_cropped.csv')
    print(f'Writing data in tabular form to {filename} (this may take some time)...')
    times_grid, latitudes_grid, longitudes_grid = [
        x.flatten() for x in np.meshgrid(times, latitudes, longitudes, indexing='ij')]
    df = pd.DataFrame({
        'time': [t.isoformat() for t in times_grid],
        'latitude': latitudes_grid,
        'longitude': longitudes_grid,
        'tmax': tmax[:].flatten()})
    df.to_csv(filename, index=False)
    print('Done')



for period in range(1979, 2014):

    f = netCDF4.Dataset('C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\\cropped_tmin_' + str(period) + '.nc')
    # Extract variable
    tmin = f.variables['tmin']
 
    # Get dimensions assuming 3D: time, latitude, longitude
    time_dim, lat_dim, lon_dim = tmax.get_dims()
    time_var = f.variables[time_dim.name]
    times = num2date(time_var[:], time_var.units)
    latitudes = f.variables[lat_dim.name][:]
    longitudes = f.variables[lon_dim.name][:]
 
    output_dir = 'C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\\' 
 
    # =====================================================================
    # Write data as a table with 4 columns: time, latitude, longitude, value
    # =====================================================================
    filename = os.path.join(output_dir, 'tmin_' + str(period) + '_cropped.csv')
    print(f'Writing data in tabular form to {filename} (this may take some time)...')
    times_grid, latitudes_grid, longitudes_grid = [
        x.flatten() for x in np.meshgrid(times, latitudes, longitudes, indexing='ij')]
    df = pd.DataFrame({
        'time': [t.isoformat() for t in times_grid],
        'latitude': latitudes_grid,
        'longitude': longitudes_grid,
        'tmin': tmin[:].flatten()})
    df.to_csv(filename, index=False)
    print('Done')
    
    
for period in range(1979, 2014):

    f = netCDF4.Dataset('C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\cropped_precip_' + str(period) + '.nc')
    # Extract variable
    precip = f.variables['precip']
 
    # Get dimensions assuming 3D: time, latitude, longitude
    time_dim, lat_dim, lon_dim = tmax.get_dims()
    time_var = f.variables[time_dim.name]
    times = num2date(time_var[:], time_var.units)
    latitudes = f.variables[lat_dim.name][:]
    longitudes = f.variables[lon_dim.name][:]
 
    output_dir = 'C:\\Users\\Francois\\Desktop\\TRABAJO UB\\Sirine\\' 
 
    # =====================================================================
    # Write data as a table with 4 columns: time, latitude, longitude, value
    # =====================================================================
    filename = os.path.join(output_dir, 'precip_' + str(period) + '_cropped.csv')
    print(f'Writing data in tabular form to {filename} (this may take some time)...')
    times_grid, latitudes_grid, longitudes_grid = [
        x.flatten() for x in np.meshgrid(times, latitudes, longitudes, indexing='ij')]
    df = pd.DataFrame({
        'time': [t.isoformat() for t in times_grid],
        'latitude': latitudes_grid,
        'longitude': longitudes_grid,
        'precip': precip[:].flatten()})
    df.to_csv(filename, index=False)
    print('Done')
