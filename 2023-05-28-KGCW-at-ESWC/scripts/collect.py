#!/usr/bin/python3
import os
import pandas as pd

# Initialize a DataFrame to store all the data
all_data = pd.DataFrame()

# Traverse the directory structure
start = "eswc-kgc-challenge-2023"
start_len = len(start) + 1

for root, dirs, files in os.walk(start):
    for file in files:
        if file == "summary.csv":
            # Construct the experiment name from the directory path
            # experiment_name = os.path.basename(os.path.dirname(os.path.dirname(root)))
            experiment_name = root[start_len:-8].replace(os.sep, '_')

            # Load the data from the CSV
            data = pd.read_csv(os.path.join(root, file))

            # Keep only the specified columns
            data = data[["step", "duration", "memory_ram_max", "cpu_user_system_diff"]]

            # Add a column for the experiment name
            data.insert(0, "Experiment name", experiment_name)

            # Append this data to the overall DataFrame
            all_data = all_data.append(data, ignore_index=True)

# Write the overall DataFrame to a CSV file
all_data.to_csv("all_data.csv", index=False)

