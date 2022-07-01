# Svoronos Kanavas Iason -- data processing trucks
#  --- load trucks df and insert column to the main df ---
# LiU May. 2022 -- construction site sonification

# store filename to var
filenameTrucks = os.getcwd()+"/fake"

# Load the .csv file
sf = pd.read_csv(filenameTrucks,skiprows=[0])

# save cat_24 column
db = sf['cat_24']

df.insert(6, "db", db, True) # insert last db column

# INFO
# 84.6403333333333 max
# 5.444976 min
