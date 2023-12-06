Config = Config or {}

Config.MinimumPolice = 0
Config.EMPTime = 90 -- amount of seconds to succeed all emps
Config.HumaneTime = 900 -- amount of seconds before humane locks down and alarm goes of

-- do not touch! Checks for correct order and sync
Config.Lockdown = false
Config.DoorsOpened = false
Config.KeycardUsed = {
	[1] = false,
	[2] = false,
}
Config.PanelHacked = false
Config.LockersPicked = false
Config.PincodeEntered = false
Config.ScalesActivated = false
Config.LootUnlocked = false

-- Loot
Config.SearchItemPool = {
    'painkillers',
    'bandage',
	-- u can add items but make sure the note is last!!!
    'stickynote'
}
Config.LootPool = {
	{Name = 'encryptedharddrive', Chance = 10},
	{Name = 'humanorgan', Chance = 25},
	{Name = 'bloodsample', Chance = 65},
}
Config.SellableItems = {
	['humanorgan'] = math.random(18000, 22000),
	['bloodsample'] = math.random(2700, 3300),
}

-- Tips that the note contains
Config.NoteText = {
	{Tip = '\"Todo: make fire extinguisher inventory (especially amount of water based)\"', Code = 14},
	{Tip = '\"Todo: make fire extinguisher inventory (especially amount of CO2 based)\"', Code = 5},
	{Tip = '\"I wonder how many of those red fire alarms we have in the facility...\"', Code = 7},
	{Tip = '\"We can keep so many animals in these cages but I don\'t know the exact number.\"', Code = 48},
	{Tip = '\"I\'m always in Test Chamber 1, I wonder how many Test Chambers we have in total...\"', Code = 6},
	{Tip = '\"Fire hoses remind me of snakes, I would be scared if there were as many snakes as fire hoses!\"', Code = 8},
	{Tip = '\"I\'m going to play a game with myself and count all the fire sprinklers in the facility!\"', Code = 43}, --
	{Tip = '\"Reminder: Order new wooden crates. Todo: Count how many\"', Code = 13},
	{Tip = '\"I need to count our fire emergency buttons to check if we have enough!\"', Code = 12},
}

-- Interact locations
Config.KeycardPosition = {
	[1] = vector3(3555.56, 3663.69, 28.12),
	[2] = vector3(3558.82, 3682.0, 28.12),
}
Config.PanelHackPosition = vector3(3523.63, 3680.77, 20.99)
Config.LockersPosition = vector3(3553.6, 3656.36, 28.12)
Config.EMPableBoxes = {
    [1] = {
        coords = vector3(3449.74, 3645.63, 42.6),
        hit = false
    },
    [2] = {
        coords = vector3(3637.82, 3747.4, 28.52),
        hit = false
    },
    [3] = {
        coords = vector3(3531.16, 3705.25, 20.99),
        hit = false
    },
}
Config.ScalePositions = {
	[1] = vector3(3556.43, 3665.4, 28.12),
	[2] = vector3(3558.96, 3680.12, 28.12),
}
Config.SearchLocations = {
	{Position = vector3(3604.38, 3739.22, 31.18), Searched = false},
	{Position = vector3(3631.52, 3738.75, 28.69), Searched = false},
	{Position = vector3(3611.37, 3715.96, 29.68), Searched = false},
	{Position = vector3(3598.21, 3720.79, 29.68), Searched = false}, 
	{Position = vector3(3587.86, 3709.60, 29.68), Searched = false},
	{Position = vector3(3586.30, 3680.07, 27.62), Searched = false},
	{Position = vector3(3581.80, 3688.17, 27.12), Searched = false},
	{Position = vector3(3560.48, 3681.13, 28.12), Searched = false},
	{Position = vector3(3564.48, 3678.81, 28.12), Searched = false},
	{Position = vector3(3558.50, 3668.62, 28.12), Searched = false},
	{Position = vector3(3559.80, 3673.95, 28.12), Searched = false},
	{Position = vector3(3558.57, 3662.51, 28.12), Searched = false},
	{Position = vector3(3549.52, 3644.13, 28.12), Searched = false},
	{Position = vector3(3540.41, 3642.39, 28.12), Searched = false},
	{Position = vector3(3529.92, 3650.26, 27.52), Searched = false},
}
Config.KeypadPosition = vector3(3587.95, 3667.42, 33.88)
Config.LootLocations = {
	{Position = vector3(3537.2, 3669.12, 28.12), Taken = false},
	{Position = vector3(3539.57, 3668.71, 28.12), Taken = false},
	{Position = vector3(3538.05, 3661.77, 28.12), Taken = false},
	{Position = vector3(3535.72, 3662.20, 28.12), Taken = false},
	{Position = vector3(3535.55, 3661.09, 28.12), Taken = false},
	{Position = vector3(3537.91, 3660.69, 28.12), Taken = false},
	{Position = vector3(3535.92, 3658.81, 28.12), Taken = false},
	{Position = vector3(3533.57, 3659.20, 28.12), Taken = false},
}
Config.EMPShop = 0 -- serversided anti dumb
Config.KeycardShop = 0 -- serversided anti dumb
Config.SellLocation = 0 -- serversided anti dumb

-- Door locations
-- do not change order, add new ones after last one
Config.Doors = {
	-- Humane Labs Gate left
	{
		objName = 'v_ilev_bl_shutter2',
		objCoords  = vector3(3627.65, 3746.76, 28.69),
	},
	-- Humane Labs Gate right
	{
		objName = 'v_ilev_bl_shutter2',
		objCoords  = vector3(3620.87, 3751.54, 28.69),
	},
	-- Humane Labs Water door
	{
		objName = 'v_ilev_bl_doorpool',
		objCoords  = vector3(3525.22, 3702.47, 20.99),
	},
	-- Decon 1 Left
	{
		objName = 'v_ilev_bl_doorsl_r',
		objCoords  = vector3(3554.99, 3664.82, 28.12),
	},
	-- Decon 1 Right
	{
		objName = 'v_ilev_bl_doorsl_l',
		objCoords  = vector3(3553.37, 3665.19, 28.12),
	},
	-- Decon 2 Left
	{
		objName = 'v_ilev_bl_doorsl_l',
		objCoords  = vector3(3556.22, 3681.45, 28.12),
	},
	-- Decon 2 Right
	{
		objName = 'v_ilev_bl_doorsl_r',
		objCoords  = vector3(3557.86, 3681.19, 28.12),
	},
	-- Lab Left
	{
		objName = 'v_ilev_bl_doorsl_l',
		objCoords  = vector3(3532.90, 3665.47, 28.12),
	},
	-- Lab Right
	{
		objName = 'v_ilev_bl_doorsl_r',
		objCoords  = vector3(3532.57, 3663.71, 28.12),
	},
}