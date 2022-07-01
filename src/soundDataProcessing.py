# Svoronos Kanavas Iason -- data processing sound
#  --- load sound df and insert column to the main df ---
# LiU Apr. 2022 -- construction site data SonVis

# store filename to var
filenameSound = os.getcwd()+"/sommargagata_dev_11_sound_30s.csv"

# Load the .csv file
sf = pd.read_csv(filenameSound, skiprows=[0])

# save cat_24 column
db = sf['cat_24']

df.insert(5, "db", db, True) # insert last db column

# 84.6403333333333 max
# 5.444976 min
