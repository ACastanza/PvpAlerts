import luadata
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from collections import defaultdict
from adjustText import adjust_text

# Set the path to your PvpAlerts.lua SavedVariables file
# savedVariablesPath = "E:\\Documents\\Elder Scrolls Online\\live\\SavedVariables\\PvpAlerts.lua"
savedVariablesPath = "E:\\Documents\\GitHub\\PvpAlerts\\PvpAlerts.lua"


# Use the Path to your PvpAlerts.lua SavedVariables file
with open(savedVariablesPath, 'r', encoding="utf-8", errors="replace") as pvpdatafile:
    pvpdata = pvpdatafile.read()
pvpdatadict = luadata.unserialize(pvpdata)

# Set the account name of the player you want to parse the detected player database for
# accountName = ""
accountName = globals().get("accountName") or list(pvpdatadict['Default'].keys())[0]

# Use the player @Name for the specific account you want to parse data for
pvpplayerdb = pvpdatadict['Default'][accountName]['$AccountWide']['Settings']['playersDB']

classColorDict = {
    'Dragonknight': (255 / 255, 125 / 255, 35 / 255),
    'Nightblade': (255 / 255, 51 / 255, 49 / 255),
    'Sorcerer': (75 / 255, 83 / 255, 247 / 255),
    'Templar': (255 / 255, 240 / 255, 95 / 255),
    'Warden': (136 / 255, 245 / 255, 125 / 255),
    'Necromancer': (97 / 255, 37 / 255, 201 / 255),
    'Arcanist': (90 / 255, 240 / 255, 80 / 255)
}

# Set the filter value for the last seen datestamp
filter_value = 1730185200  # Last Seen Datestamp since U44 Release
# filter_value = 0  #Last Seen Datestamp since August ~27th, 2023 
# filter_value = 1742799601  #Last Seen Datestamp since Vengeance Release (March 24st, 2025)
# filter_value = 1742886001  #Last Seen Datestamp since Vengeance Day2 (March 24st, 2025)

classDict = {1: 'Dragonknight', 2: 'Sorcerer', 3: 'Nightblade', 4: 'Warden', 5: 'Necromancer', 6: 'Templar', 117: 'Arcanist'}

# Initialize dictionaries for class, alliance, and rank breakdown
countByClassID = {}
allianceDict = {1: 'Aldmeri Dominion', 2: 'Ebonheart Pact', 3: 'Daggerfall Covenant'}

countByAllianceAndClass = {alliance: {class_name: 0 for class_name in classDict.values()} for alliance in allianceDict.keys()}
uniqueCharactersByAccount = defaultdict(int)
rankByCharacter = defaultdict(int)
rankByFaction = {alliance: defaultdict(int) for alliance in allianceDict.keys()}
characterCountDistributionByFaction = {alliance: defaultdict(int) for alliance in allianceDict.keys()}
rankCounts = defaultdict(int)  # Track distinct characters at each alliance rank (0-50)

# Initialize dictionary for race breakdown by class and faction
raceDict = {
    1: 'Breton', 2: 'Redguard', 3: 'Orc', 4: 'Dark Elf', 5: 'Nord', 6: 'Argonian',
    7: 'High Elf', 8: 'Wood Elf', 9: 'Khajiit', 10: 'Imperial'
}
raceByClassAndFaction = {
    alliance: {class_name: defaultdict(int) for class_name in classDict.values()}
    for alliance in allianceDict.keys()
}

# Initialize dictionary for race breakdown by class (ignoring factions)
raceByClassOverall = {class_name: defaultdict(int) for class_name in classDict.values()}

# Initialize dictionary for race breakdown by faction
raceByFaction = {alliance: defaultdict(int) for alliance in allianceDict.keys()}

# Iterate over each character's data to populate all dictionaries
for character_data in pvpplayerdb.values():
    last_seen = character_data.get('lastSeen', 0)
    if last_seen > filter_value:
        unit_class = character_data.get('unitClass')
        unit_alliance = character_data.get('unitAlliance')
        unit_acc_name = character_data.get('unitAccName')
        unit_rank = character_data.get('unitAvARank')
        unit_race = character_data.get('unitRace')

        # Update countByClassID
        if unit_class is not None:
            countByClassID[unit_class] = countByClassID.get(unit_class, 0) + 1

            # Update countByAllianceAndClass
            if unit_alliance in allianceDict:
                class_name = classDict.get(unit_class)
                if class_name:
                    countByAllianceAndClass[unit_alliance][class_name] += 1

        # Update uniqueCharactersByAccount
        if unit_acc_name:
            uniqueCharactersByAccount[unit_acc_name] += 1

            # Update characterCountDistributionByFaction
            if unit_alliance in allianceDict:
                characterCountDistributionByFaction[unit_alliance][uniqueCharactersByAccount[unit_acc_name]] += 1

        # Update rankByCharacter
        if unit_acc_name and unit_rank is not None:
            rankByCharacter[unit_acc_name] += unit_rank

            # Update rankByFaction
            if unit_alliance in allianceDict:
                rankByFaction[unit_alliance][unit_rank] += 1

        # Update rankCounts for distinct characters at each rank
        if unit_rank is not None:
            rankCounts[unit_rank] += 1

        # Update raceByClassAndFaction and raceByClassOverall
        if unit_class in classDict and unit_alliance in allianceDict and unit_race in raceDict:
            class_name = classDict[unit_class]
            race_name = raceDict[unit_race]
            raceByClassAndFaction[unit_alliance][class_name][race_name] += 1
            raceByClassOverall[class_name][race_name] += 1

        # Update raceByFaction
        if unit_alliance in allianceDict and unit_race in raceDict:
            race_name = raceDict[unit_race]
            raceByFaction[unit_alliance][race_name] += 1

# Construct countByClass from countByClassID
countByClass = {classDict[key]: value for key, value in countByClassID.items()}

# Sort countByClass based on classDict keys
sorted_countByClass = {classDict[key]: countByClass[classDict[key]] for key in sorted(classDict.keys()) if classDict[key] in countByClass}

# Extract class names and counts
classes = list(sorted_countByClass.keys())
counts = list(sorted_countByClass.values())

# Get colors for each class
colors = [classColorDict[class_name] for class_name in classes]

# Create subplots for bar chart and pie chart
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Bar chart
axes[0].bar(classes, counts, color=colors)
axes[0].set_xlabel('Class')
axes[0].set_ylabel('Count')
axes[0].set_title('Count by Class')
axes[0].set_xticklabels(classes, rotation=45)

# Annotate bars with counts
for i, bar in enumerate(axes[0].containers[0]):
    axes[0].text(bar.get_x() + bar.get_width() / 2, bar.get_height(), str(counts[i]), ha='center', va='bottom')

# Pie chart
axes[1].pie(counts, labels=classes, autopct='%1.1f%%', colors=colors, startangle=140)
axes[1].set_title('Class Distribution')

plt.tight_layout()

# Save the plot
current_date = datetime.now().strftime("%Y-%m-%d")
filename = f"Class_Counts_and_Distribution_{current_date}.png"
plt.savefig(filename)

# Display the filename for confirmation
print(f"Plot saved as {filename}")

# Generate plots for each alliance
fig, axes = plt.subplots(3, 2, figsize=(14, 18))
fig.suptitle('Class Breakdown by Alliance', fontsize=16)

for idx, (alliance, class_counts) in enumerate(countByAllianceAndClass.items()):
    classes = list(class_counts.keys())
    counts = list(class_counts.values())
    colors = [classColorDict[class_name] for class_name in classes]

    # Bar chart
    axes[idx, 0].bar(classes, counts, color=colors)
    axes[idx, 0].set_xlabel('Class')
    axes[idx, 0].set_ylabel('Count')
    axes[idx, 0].set_title(f'{allianceDict[alliance]} - Count by Class')
    axes[idx, 0].set_xticklabels(classes, rotation=45)

    # Annotate bars with counts
    for i, bar in enumerate(axes[idx, 0].containers[0]):
        axes[idx, 0].text(bar.get_x() + bar.get_width() / 2, bar.get_height(), str(counts[i]), ha='center', va='bottom')

    # Pie chart
    axes[idx, 1].pie(counts, labels=classes, autopct='%1.1f%%', colors=colors, startangle=140)
    axes[idx, 1].set_title(f'{allianceDict[alliance]} - Class Distribution')

plt.tight_layout(rect=[0, 0, 1, 0.96])

# Save the plot
filename = f"Class_Breakdown_by_Alliance_{current_date}.png"
plt.savefig(filename)

# Display the filename for confirmation
print(f"Plot saved as {filename}")

# Aggregate the counts of accounts by the number of characters
characterCounts = list(uniqueCharactersByAccount.values())
characterCountDistribution = defaultdict(int)
for count in characterCounts:
    characterCountDistribution[count] += 1

# Prepare data for the histogram
x_values = list(characterCountDistribution.keys())
y_values = list(characterCountDistribution.values())

# Create a histogram
plt.figure(figsize=(10, 6))
plt.bar(x_values, y_values, color='skyblue')
plt.xlabel('Number of Characters')
plt.ylabel('Number of Accounts')
plt.title('Distribution of Characters per Account')
plt.xticks(x_values, rotation=45, ha='right')  # Ensure all x-axis labels are shown
plt.tight_layout()

# Save the histogram
filename = f"Characters_per_Account_{current_date}.png"
plt.savefig(filename)

# Display the filename for confirmation
print(f"Histogram saved as {filename}")

# Define a consistent color mapping for the number of characters
character_count_colors = plt.cm.tab20.colors  # Use a standard categorical color map
color_mapping = defaultdict(
    lambda: character_count_colors[len(color_mapping) % len(character_count_colors)],  # Assign a color dynamically if missing
    {count: character_count_colors[i % len(character_count_colors)] for i, count in enumerate(sorted(characterCountDistribution.keys()))}
)

# Create subplots for character count distribution by faction (bar chart and pie chart for each faction)
fig, axes = plt.subplots(len(characterCountDistributionByFaction), 2, figsize=(14, 6 * len(characterCountDistributionByFaction)))
fig.suptitle('Character Count Distribution by Faction', fontsize=16)

for idx, (alliance, distribution) in enumerate(characterCountDistributionByFaction.items()):
    # Bar chart for faction
    x_values = list(distribution.keys())
    y_values = list(distribution.values())
    axes[idx, 0].bar(x_values, y_values, color='skyblue')
    axes[idx, 0].set_xlabel('Number of Characters')
    axes[idx, 0].set_ylabel('Number of Accounts')
    axes[idx, 0].set_title(f'{allianceDict[alliance]} - Characters per Account')
    axes[idx, 0].set_xticks(x_values)
    axes[idx, 0].set_xticklabels(x_values, rotation=45, ha='right')

    # Pie chart for faction with tiled labels
    faction_counts = list(distribution.values())
    faction_labels = [f"{key} Characters" for key in distribution.keys()]
    faction_colors = [color_mapping[key] for key in distribution.keys()]
    wedges, texts = axes[idx, 1].pie(
        faction_counts, colors=faction_colors, startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
    )

    # Offset labels and include percentages in labels only
    label_positions = []  # Store positions of labels to avoid overlap
    for i, text in enumerate(texts):
        percentage = f"{faction_counts[i] / sum(faction_counts) * 100:.1f}%"
        text.set_text(f"{faction_labels[i]} ({percentage})")
        text.set_fontsize(8)
        text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
        text.set_horizontalalignment('center')

        # Calculate the center of the slice
        theta = (wedges[i].theta1 + wedges[i].theta2) / 2
        x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
        y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

        # Adjust y-coordinate to tile down and around the pie
        for pos in label_positions:
            if abs(y - pos[1]) < 0.15:  # Check for overlap
                y -= 0.15  # Move label down
        label_positions.append((x, y))

        text.set_position((x, y))  # Adjust label position

        # Draw lines to slices
        x_slice = wedges[i].r * np.cos(np.radians(theta))
        y_slice = wedges[i].r * np.sin(np.radians(theta))
        axes[idx, 1].annotate(
            '', xy=(x_slice, y_slice), xytext=(x, y),
            arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
        )

    axes[idx, 1].set_title(f'{allianceDict[alliance]} - Character Count Distribution')

plt.tight_layout(rect=[0.1, 0, 1, 0.95])

# Save the plot
filename = f"Character_Count_Distribution_by_Faction_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Create subplots for total character count distribution (bar chart and pie chart)
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Bar chart for total character count distribution
axes[0].bar(x_values, y_values, color='skyblue')
axes[0].set_xlabel('Number of Characters')
axes[0].set_ylabel('Number of Accounts')
axes[0].set_title('Distribution of Characters per Account')
axes[0].set_xticks(x_values)
axes[0].set_xticklabels(x_values, rotation=45, ha='right')

# Prepare data for the pie chart
total_counts = list(characterCountDistribution.values())
total_labels = [f"{key} Characters" for key in characterCountDistribution.keys()]
total_colors = [color_mapping[key] for key in characterCountDistribution.keys()]

# Sort slices by size
sorted_indices = sorted(range(len(total_counts)), key=lambda i: total_counts[i], reverse=True)
sorted_counts = [total_counts[i] for i in sorted_indices]
sorted_labels = [total_labels[i] for i in sorted_indices]
sorted_colors = [total_colors[i] for i in sorted_indices]

# Pie chart for total character count distribution with tiled labels
wedges, texts = axes[1].pie(
    sorted_counts, colors=sorted_colors, startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
)

# Offset labels and include percentages in labels only
label_positions = []  # Store positions of labels to avoid overlap
for i, text in enumerate(texts):
    percentage = f"{sorted_counts[i] / sum(sorted_counts) * 100:.1f}%"
    text.set_text(f"{sorted_labels[i]} ({percentage})")
    text.set_fontsize(8)
    text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
    text.set_horizontalalignment('center')

    # Calculate the center of the slice
    theta = (wedges[i].theta1 + wedges[i].theta2) / 2
    x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
    y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

    # Adjust y-coordinate to tile down and around the pie
    for pos in label_positions:
        if abs(y - pos[1]) < 0.15:  # Check for overlap
            y -= 0.15  # Move label down
        label_positions.append((x, y))

    text.set_position((x, y))  # Adjust label position

    # Draw lines to slices
    x_slice = wedges[i].r * np.cos(np.radians(theta))
    y_slice = wedges[i].r * np.sin(np.radians(theta))
    axes[1].annotate(
        '', xy=(x_slice, y_slice), xytext=(x, y),
        arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
    )

axes[1].set_title('Total Character Count Distribution')

plt.tight_layout()

# Save the combined plot
filename = f"Characters_per_Account_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Plot: Alliance Rank by Character
accountNames = list(rankByCharacter.keys())
rankSums = list(rankByCharacter.values())

# Plot: Alliance Rank by Character (Dynamic Range)
ranks = sorted(rankCounts.keys())  # Dynamically calculate ranks based on present data
counts = [rankCounts[rank] for rank in ranks]

plt.figure(figsize=(10, 6))
plt.bar(ranks, counts, color='orange')
plt.xlabel('Alliance Rank')
plt.ylabel('Number of Characters')
plt.title('Alliance Rank Distribution')
plt.xticks(ranks, rotation=45, ha='right')
plt.tight_layout()

# Save the plot
filename = f"Alliance_Rank_Distribution_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Plot: Alliance Rank by Faction
fig, axes = plt.subplots(3, 1, figsize=(10, 18))
fig.suptitle('Alliance Rank Breakdown by Faction', fontsize=16)

# Define colors for each faction
allianceColors = [
    (187 / 255, 164 / 255, 71 / 255),  # Gold for AD
    (221 / 255, 91 / 255, 78 / 255),   # Maroon for EP
    (79 / 255, 128 / 255, 188 / 255)   # Navy Blue for DC
]

for idx, (alliance, rank_counts) in enumerate(rankByFaction.items()):
    ranks = list(rank_counts.keys())
    counts = list(rank_counts.values())

    axes[idx].bar(ranks, counts, color=allianceColors[idx])
    axes[idx].set_xlabel('Alliance Rank')
    axes[idx].set_ylabel('Count')
    axes[idx].set_title(f'{allianceDict[alliance]} - Alliance Rank Distribution')

plt.tight_layout(rect=[0, 0, 1, 0.96])

# Save the plot
filename = f"Alliance_Rank_by_Faction_{current_date}.png"
plt.savefig(filename)

# Display the filename for confirmation
print(f"Plot saved as {filename}")

# Generate plot for race breakdown by class
fig, axes = plt.subplots(1, len(classDict), figsize=(35, 12))  # Larger figure for better spacing
fig.suptitle('Race Breakdown by Class', fontsize=18, y=1.05)  # Move title up

for col_idx, (class_name, race_counts) in enumerate(raceByClassOverall.items()):
    sorted_races = sorted(race_counts.keys(), key=lambda race: list(raceDict.values()).index(race))
    counts = [race_counts[race] for race in sorted_races]
    total = sum(counts)

    ax = axes[col_idx]

    wedges, texts = ax.pie(
        counts, colors=plt.cm.tab20.colors[:len(sorted_races)], startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
    )

    # Offset labels and include percentages in labels only
    label_positions = []  # Store positions of labels to avoid overlap
    for i, text in enumerate(texts):
        percentage = f"{counts[i] / total * 100:.1f}%"
        text.set_text(f"{sorted_races[i]} ({percentage})")
        text.set_fontsize(8)
        text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
        text.set_horizontalalignment('center')

        # Calculate the center of the slice
        theta = (wedges[i].theta1 + wedges[i].theta2) / 2
        x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
        y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

        # Adjust y-coordinate to tile down and around the pie
        for pos in label_positions:
            if abs(y - pos[1]) < 0.15:  # Check for overlap
                y -= 0.15  # Move label down
            label_positions.append((x, y))

        text.set_position((x, y))  # Adjust label position

        # Draw lines to slices
        x_slice = wedges[i].r * np.cos(np.radians(theta))
        y_slice = wedges[i].r * np.sin(np.radians(theta))
        ax.annotate(
            '', xy=(x_slice, y_slice), xytext=(x, y),
            arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
        )

    ax.set_title(class_name, fontsize=12, y=-0.1)  # Adjust title position to avoid overlap

plt.tight_layout(rect=[0, 0, 1, 0.95])  # Adjust layout
filename = f"Race_Breakdown_by_Class_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Compute figure size dynamically based on number of factions
fig_height = 4 * len(raceByClassAndFaction)  # Scale height dynamically
fig, axes = plt.subplots(len(raceByClassAndFaction), len(classDict), figsize=(40, fig_height))

fig.suptitle('Race Breakdown by Class and Faction', fontsize=18, y=1.02)

# Add class headers dynamically above each column
for col_idx, class_name in enumerate(classDict.values()):
    # Dynamically calculate the center of each column using the axes positions
    x_position = axes[0, col_idx].get_position().x0 + axes[0, col_idx].get_position().width / 2
    # Adjust for padding between columns (wspace) with a slightly reduced adjustment factor
    padding_adjustment = col_idx * fig.subplotpars.wspace * axes[0, col_idx].get_position().width / 2
    fig.text(x_position + padding_adjustment, fig.subplotpars.top + 0.1, class_name, 
             ha='center', va='center', fontsize=14, fontweight='bold')  # Move headers further up

plt.subplots_adjust(left=0.1, hspace=0.2, wspace=0.4)  # Adjust left padding to ensure row titles are visible

for row_idx, (alliance, class_race_counts) in enumerate(raceByClassAndFaction.items()):
    # Dynamically calculate the center of each row for row titles
    y_position = axes[row_idx, 0].get_position().y0 + axes[row_idx, 0].get_position().height / 2
    fig.text(0.05, y_position, allianceDict[alliance], ha='center', va='center',
             fontsize=14, fontweight='bold', rotation='vertical')  # Adjusted left margin for row titles

    for col_idx, (class_name, race_counts) in enumerate(class_race_counts.items()):
        sorted_races = sorted(race_counts.keys(), key=lambda race: list(raceDict.values()).index(race))
        counts = [race_counts[race] for race in sorted_races]
        total = sum(counts)

        ax = axes[row_idx, col_idx] if len(raceByClassAndFaction) > 1 else axes[col_idx]

        wedges, texts = ax.pie(
            counts, colors=plt.cm.tab20.colors[:len(sorted_races)], startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
        )

        # Offset labels and include percentages in labels only
        label_positions = []  # Store positions of labels to avoid overlap
        for i, text in enumerate(texts):
            percentage = f"{counts[i] / total * 100:.1f}%"
            text.set_text(f"{sorted_races[i]} ({percentage})")
            text.set_fontsize(8)
            text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
            text.set_horizontalalignment('center')

            # Calculate the center of the slice
            theta = (wedges[i].theta1 + wedges[i].theta2) / 2
            x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
            y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

            # Adjust y-coordinate to tile down and around the pie
            for pos in label_positions:
                if abs(y - pos[1]) < 0.15:  # Check for overlap
                    y -= 0.15  # Move label down
                label_positions.append((x, y))

            text.set_position((x, y))  # Adjust label position

            # Draw lines to slices
            x_slice = wedges[i].r * np.cos(np.radians(theta))
            y_slice = wedges[i].r * np.sin(np.radians(theta))
            ax.annotate(
                '', xy=(x_slice, y_slice), xytext=(x, y),
                arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
            )

plt.tight_layout(rect=[0.1, 0, 1, 0.95])

# Save the plot
filename = f"Race_Breakdown_by_Class_and_Faction_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Generate plot for race breakdown by faction
fig, axes = plt.subplots(1, len(allianceDict), figsize=(20, 6))
fig.suptitle('Race Breakdown by Faction', fontsize=16)

for col_idx, (alliance, race_counts) in enumerate(raceByFaction.items()):
    sorted_races = sorted(race_counts.keys(), key=lambda race: list(raceDict.values()).index(race))
    counts = [race_counts[race] for race in sorted_races]
    total = sum(counts)

    ax = axes[col_idx]
    wedges, texts = ax.pie(
        counts, colors=plt.cm.tab20.colors[:len(sorted_races)], startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
    )

    # Offset labels and include percentages in labels only
    label_positions = []  # Store positions of labels to avoid overlap
    for i, text in enumerate(texts):
        percentage = f"{counts[i] / total * 100:.1f}%"
        text.set_text(f"{sorted_races[i]} ({percentage})")
        text.set_fontsize(8)
        text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
        text.set_horizontalalignment('center')

        # Calculate the center of the slice
        theta = (wedges[i].theta1 + wedges[i].theta2) / 2
        x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
        y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

        # Adjust y-coordinate to tile down and around the pie
        for pos in label_positions:
            if abs(y - pos[1]) < 0.15:  # Check for overlap
                y -= 0.15  # Move label down
        label_positions.append((x, y))

        text.set_position((x, y))  # Adjust label position

        # Draw lines to slices
        x_slice = wedges[i].r * np.cos(np.radians(theta))
        y_slice = wedges[i].r * np.sin(np.radians(theta))
        ax.annotate(
            '', xy=(x_slice, y_slice), xytext=(x, y),
            arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
        )

    # Add faction label below each pie chart
    ax.set_title(allianceDict[alliance], fontsize=12, pad=20)

plt.tight_layout(rect=[0, 0, 1, 0.9])

# Save the plot
filename = f"Race_Breakdown_by_Faction_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")

# Aggregate player counts by faction
faction_counts = {allianceDict[alliance]: sum(class_counts.values()) for alliance, class_counts in countByAllianceAndClass.items()}

# Prepare data for the pie chart
factions = list(faction_counts.keys())
counts = list(faction_counts.values())
total = sum(counts)

# Create the pie chart
plt.figure(figsize=(8, 8))
wedges, texts = plt.pie(
    counts, colors=allianceColors, startangle=140, wedgeprops=dict(linewidth=1, edgecolor='black')
)

# Offset labels and include counts with percentages
label_positions = []  # Store positions of labels to avoid overlap
for i, text in enumerate(texts):
    percentage = f"{counts[i] / total * 100:.1f}%"
    text.set_text(f"{factions[i]} ({counts[i]} - {percentage})")
    text.set_fontsize(8)
    text.set_bbox(dict(facecolor="white", alpha=0.7, edgecolor="none", boxstyle="round,pad=0.2"))
    text.set_horizontalalignment('center')

    # Calculate the center of the slice
    theta = (wedges[i].theta1 + wedges[i].theta2) / 2
    x = 1.2 * wedges[i].r * np.cos(np.radians(theta))
    y = 1.2 * wedges[i].r * np.sin(np.radians(theta))

    # Adjust y-coordinate to tile down and around the pie
    for pos in label_positions:
        if abs(y - pos[1]) < 0.15:  # Check for overlap
            y -= 0.15  # Move label down
    label_positions.append((x, y))

    text.set_position((x, y))  # Adjust label position

    # Draw lines to slices
    x_slice = wedges[i].r * np.cos(np.radians(theta))
    y_slice = wedges[i].r * np.sin(np.radians(theta))
    plt.annotate(
        '', xy=(x_slice, y_slice), xytext=(x, y),
        arrowprops=dict(arrowstyle="-", color='gray', lw=0.5)
    )

plt.title('Character Distribution by Faction')

# Save the plot
filename = f"Player_Distribution_by_Faction_{current_date}.png"
plt.savefig(filename)
print(f"Plot saved as {filename}")
