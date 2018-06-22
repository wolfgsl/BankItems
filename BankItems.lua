--[[*****************************************************************
	BankItems v60200
	17th October 2014

	Author: Xinhuan @ US Frostmourne Alliance
	Fixes: by many addon Fans.
	*****************************************************************
	Description:
		Type /bi or /bankitems to see what is currently in your
		bank.  You must visit your bank once to initialize.

		An addon that remembers the contents of your bank, bags,
		mail, equipped, currency, AH, void storage and display
		them anywhere in the world.

		Also able to remember/display the banks of any character
		on the same account on any server, as well as searching
		and exporting lists of bag/bank items out.

		BankItems will also remember the contents of Guild Banks
		if you are able to view them. Use /bigb to see them. Note
		that Guild Banks are a shared repository and changes can
		occur to it by other members of your guild.


	- Curse: http://www.curse.com/addons/wow/bank-items
	- Project site: http://www.wowace.com/addons/bank-items/
	- GitHub: https://github.com/JoseJimeniz/BankItems


	Plugins:
		These plugins allow clicking on the panel/plugin icon to
		open BankItems, giving a summarised view money of each
		character on the same realm.

		Titan Panel - http://wowui.incgamers.com/?p=mod&m=3848
		FuBar       - http://www.wowace.com/projects/bank-items-fu
		LDB         - Supplied by BankItems if LDB is detected

		Note: I no longer support the Titan Panel plugin.

	Commands:
		/bi : open BankItems
		/bi all : open BankItems and all bags
		/bi allbank: open BankItems and all bank bags only
		/bi clear : clear currently selected player's info
		/bi clearall : clear all players' info
		/bi showbuttun : show the minimap button
		/bi hidebutton : hide the minimap button
		/bi search itemname : search for items
		/bis itemname : search for items
		/bigb : open BankItems guild bank
		/bigb clear : clear currently selected guild's info

		Most options are found in the GUI options panel.

	Not a bug:
		If you close your bank after retrieving/storing an item in it
		too quickly and the server hasn't updated your inventory,
		BankItems is unable to record the change to your bank when the
		item actually moves later. The WoW API does not give you any
		data about your bank once BANK_FRAME_CLOSED event has fired.

	Credits:
		Original concept from Merphle.
		Last maintained by JASlaughter, then Galmok@Stormrage-EU.
	*****************************************************************

Xinhuan's Note:
	This addon replaces the Blizzard function updateContainerFrameAnchors() in ContainerFrame.lua
	if the option is set to open the BankItems bags along with the Blizzard default bags. This may
	break any addon(s) that hook this function, but see no real reason why anyone would ever hook
	that function in the first place.

	updateContainerFrameAnchors() is the very last function called by
	UIParent_ManageFramePositions(), hence tainting it shouldn't be an issue for petbars or any
	other frame. Also, note that UIParent_ManageFramePositions() is almost always securecalled
	from other functions in Blizzard code.
]]

--------------------
-- Patch Notes:

-- Updated to handle larger than 16 slot bags by Galmok@Stormrage-EU: Version 11000
-- Removed double variable definitions (first defined in ContainerFrame.lua): Version 11001
-- Updated to be patch 1.11 compatible (bag texture fix) by Galmok@Stormrage-EU: Version 11100


-- 2 December 2006, by Xinhuan @ Blackrock US Alliance: Version 20000
-- Updated to be TBC v2.0.2 compliant.
-- BankItems expanded to include the 4 extra bank slots and 1 bank bag slot in the expansion.
-- BankItems bags will now use the right side of the screen like normal bags and stack with them.
-- Removed the "resetpos" option since all frames are now not movable.
-- Updated link parsing format to TBC itemlinks.
-- Fixed the dropdown menu bug.


-- 6 December 2006, by Xinhuan @ Blackrock US Alliance: Version 20001
-- Updated to be Live Servers v2.0.1.6180 compliant.
-- Added function to upgrade saved data to TBC itemlink format.


-- 10 January 2007, by Xinhuan @ Blackrock US Alliance: Version 20300
-- For use with Live Servers v2.0.3.6299. TOC update to 20003.
-- NEW: BankItems will now also remember the contents of your 5 inventory bags.
-- NEW: BankItems Will now remember purchased and unused bank bag slots (grey/red background).
-- NEW: Added optional draggable minimap button.
-- NEW: Added "/bi showbutton" and "/bi hidebutton" to show and hide the minimap button.
-- NEW: The BankItems main window is now movable (and cannot be dragged offscreen).
-- NEW: You can now set the scale and transparency of BankItems. The default scale is now 80%.
-- NEW: Added GUI options panel which contain most of the available options.
-- UPDATED: When hovering over the bag portrait of an open BankItems bagframe, the tooltip will now show the bag link.
-- CHANGED/FIXED: Changed the way BankItems bags show. They will no longer open up together with the normal bags because doing so taints the default UI and causes the petbar not to show/hide in combat. They will now open next to the BankItems main bank frame instead.
-- FIXED: Fixed extra spaces that can appear on "/bi list".
-- FIXED: Removed invisible "unclickable" space below the BankItems main bank frame.
-- FIXED: Fixed error due to ContainerIDToInventoryID(bagID) API change. Inputs outside the range of 1-11 (4 bag and 7 bank) are no longer valid input.
-- NEW: FuBar and Titan Panel plugins for BankItems are now available.
--
-- Because up to 12 possible bags can be displayed, users are adviced to change the scale in the GUI options.


-- 17 January 2007, by Xinhuan @ Blackrock US Alliance: Version 20500
-- For use with Live Servers v2.0.5.6320. TOC remains at 20003 (don't ask me why).
-- FIXED: Fixed a rare possible error with item link parsing.
-- CHANGED: BankItems normal inventory bags will now have normal bag textures to match the default UI. This makes it easier to tell which ones are bank bags and which aren't.


-- 26 January 2007, by Xinhuan @ Blackrock US Alliance: Version 20600
-- For use with Live Servers v2.0.6.6337. TOC remains at 20003.
-- NEW: Added an extra keybind and slash command option (/bi allbank) to only open bank bags as opposed to all bags.
-- NEW: Added in Auctioneer tooltip support for BankItems (thanks Knaledge).
-- NEW: Readded in the option to open the BankItem bags along with the default bags in the bottom right corner as per in v20300, because tainting issues are fixed.


-- 5 February 2007, by Xinhuan @ Blackrock US Alliance: Version 20601
-- For use with Live Servers v2.0.6.6337. TOC remains at 20003.
-- NEW: Added an option to make the BankItems main frame behave like Blizzard frames (will push frames to the right). However, this only works at 100% frame scaling.
-- NEW: Added a little hook to support Saeris Lootlink tooltips.
-- NEW: Added an option to change the default behavior of "/bi" without having to add the "all" or "allbank" options.
-- NEW: You can now export a list of items in your bags/bank by copying text from an export window.
-- FIXED: BankItems will now work with OneBank, Bagnon and other bag/bank type addons.


-- 5 February 2007, by Xinhuan @ Blackrock US Alliance: Version 20602
-- FIXED: Fixed the errors that occur on hitting the Options Button due to a mistake.


-- 17 April 2007, by Xinhuan @ Blackrock US Alliance: Version 20603
-- For use with Live Servers v2.0.12.6546. TOC remains at 20003.
-- NEW: BankItems will now remember the 20 items that are equipped on each character.
-- NEW: Added HealPoints tooltip support.
-- CHANGED: The user dropdown list is now sorted alphabetically by name then by realm (for characters of the same name on multiple realms).
-- FIXED: Saeris LootLink, Auctioneer and other Auctioneer related addons will now show information with the correct stack sizes instead of 1 item.


-- 31 May 2007, by Xinhuan @ Blackrock US Alliance: Version 21000
-- For use with Live Servers v2.1.0.6729. TOC update to 20100.
-- NEW: Added some extra options for item groupings and no-preformatting for exporting bank content.


-- 21 June 2007, by Xinhuan @ Blackrock US Alliance: Version 21001
-- For use with Live Servers v2.1.2.6803.
-- UPDATED: BankItems will now generate minimal garbage to be collected (memory efficiency). It used to generate as much as 50kb of garbage on _every_ inventory change.
-- NEW: BankItems will now remember where your character last logged out and display it in the BankItems frame title.


-- 17 August 2007, by Xinhuan @ Blackrock US Alliance: Version 21002
-- For use with Live Servers v2.1.3.6898.
-- FIXED: Opening and closing BankItems with keybindings will no longer cause Blizzard frames to behave oddly.
-- NEW: BankItems will now remember your items and cumulative gold in the mailbox when you visit it.
-- NEW: You may now search for items by name using "/bi search itemname".


-- 24 August 2007, by Xinhuan @ Blackrock US Alliance: Version 22000
-- For use with Live Servers v2.1.3.6898 and PTR Servers v0.2.0.7125.
-- UPDATED: Rewrote BankItems fully using the latest available APIs and layout functions. The original addon was written 2 years ago.
-- UPDATED: Improved load time, speed, efficiency, garbage generation, event handling. Lowered memory usage, removed redundant code.
-- UPDATED: Rewrote event handling code so that BankItems will no longer record your whole inventory multiple times on bag/equipped changes. This means when you change equipment sets using closetgnome/itemrack/etc, it will only record changes once and not as much as 38 times.
-- UPDATED: When something in your bags change, BankItems will now only record the affected bag(s) once instead of your whole inventory.
-- UPDATED: BankItems no longer uses XML files. BankItems.xml is still included as a zero-byte file to overwrite the old 49KB file and can be deleted.
-- REMOVED: Removed '/bi list' because it is useless and text exporting is already available.
-- FIXED: Occasional inverted toggle for 'Show Bag Prefix' option.
-- FIXED: Clicking on bags/items in BankItems no longer inserts a link when typing a message if the Shift key isn't held down.
-- FIXED: BankItems will no longer stop recording bags at the first empty bag slot it found (if for some reason you skipped bag slots).
-- FIXED: Bankitems will now store items when you leave/close the mailbox instead of opening to avoid a possible WoW client hang.
-- FIXED: Hopefully fixed the Auctioneer/EnhTooltip tooltip display bugs.
-- CHANGED: Mailbag display has been changed to a single bag with next/prev buttons to allow unlimited mail to be shown.
-- NEW: Added a number in brackets indicating the total number of each item found when using 'Group similar items' mode while using /bi search itemname.
-- NEW: Items and money that are sent to known alts on your account are saved in the BankItems recipient's mailbag directly.


-- 1st October 2007, by Xinhuan @ Blackrock US Alliance: Version 22001
-- For use with Live Servers v2.2.0.7272. TOC update to 20200.
-- CHANGED: Pressing Esc will now close the export/search results window.
-- CHANGED: Made the search results more readable and more detailed.
-- CHANGED: Changed options so that you can now choose which bags (bank, inventory, equipped, mail) to open on /bi.
-- NEW: Added /bis as a shortcut for /bi search.
-- NEW: Added button to bring up the search results window.
-- NEW: Added checkbox to only search the current realm instead of all realms.
-- REMOVED: Removed EnhTooltip and Stubby from OptionalDeps. They are no longer required to load before BankItems.
-- FIXED: Attempted to fix line 1555 concatenate local 'recipient' nil error.
-- FIXED: Fixed Export and Search only counting the first 18 slots of the mail bag.


-- 27th November 2007, by Xinhuan @ Blackrock US Alliance: Version 23000
-- For use with Live Servers v2.3.0.7561. TOC update to 20300.
-- FIXED: Removed the "Behavior" character from appearing on the dropdown list when "Show All Realms" is selected.
-- UPDATED: Updated BankItems to work with multiple attachments mail in 2.3.
-- UPDATED: Split off localization into its own file. Removed the empty XML file.
-- ADDED: Added Chinese and Taiwan localizations by Isler.
-- ADDED: Added search filters to choose which bags to search.
-- ADDED: Added initial guild banks support. This is still in early stages.
-- ADDED: Added optional tooltip data display showing how many of the same item you have. Using this option may cost a slight performance hit. You can disable this in the options.


-- 25th December 2007, by Xinhuan @ Blackrock US Alliance: Version 23001
-- For use with Live Servers v2.3.0.7561.
-- UPDATED: BankItems Guild Bank (BIGB) frame is now movable.
-- UPDATED: Transparency, scale and movement settings now also apply on BIGB.
-- ADDED: Added show all realms checkbox to BIGB.
-- ADDED: Added keybinding to open BIGB.
-- FIXED: Fixed an issue that can potentially result in the X, Options and other buttons being shown near the minimap.
-- UPDATED: The BIGB display will now update along with the real guild bank if both are open and changes are detected.
-- ADDED: Added initial support for exporting BIGB.
-- ADDED: Guild banks can now be searched in addition to your own banks.
-- ADDED: Guild tabards now show up on BIGB.
-- ADDED: Added '/bigb clear' command to delete guilds from BankItems.
-- UPDATED: Added tooltip data display to itemlinks clicked in chat. Added a summed total line if more than 1 character has the item.
-- UPDATED: You may now search for items using a direct itemlink (/bis [itemlink]) instead of typing it out.
-- ADDED: You may now selectively choose guild banks to be included in the tooltip data display (for you people with personal guild banks).
-- ADDED: Added French localization by pettigrow.
-- UPDATED: Add tooltip support for some addons.


-- 2nd January 2008, by Xinhuan @ Blackrock US Alliance: Version 23002
-- FIXED: Add a tooltip:Show() to force tooltip repainting after adding tooltip information.
-- FIXED: *Very* aggressively cache tooltip text that is added for performance (slight memory increase).
-- FIXED: Switched method of hooking tooltips to improve performance (credit to Siz).
-- FIXED: Rebuild alt-cache on returning items to an existing alt.
-- ADDED: Added a button to open BIGB in BankItems.


-- 9th January 2008, by Xinhuan @ Blackrock US Alliance: Version 23003
-- For use with Live Servers v2.3.2.7741.
-- FIXED: Fix for BankItems.lua: 3894: attempt to call global 'GetUIPanelWindowInfo' (a nil value)


-- 27th March 2008, by Xinhuan @ Blackrock US Alliance: Version 24000
-- For use with Live Servers v2.4.0.8089.
-- ADDED: Store mail expiry time for each item in the mailbox.
-- ADDED: New option to ignore soulbound items that are not stackable for tooltip information.
-- UPDATED: Moved the options window into the default UI's new Interace Options panel.


-- 16th May 2008, by Xinhuan @ Blackrock US Alliance: Version 24001
-- For use with Live Servers v2.4.2.8278.
-- CODING: Removed redundant semicolons and brackets.
-- FIXED: Fix deleted/returned flags that mark if a mail item is going to be deleted or returned when it expires. Existing incorrect flags remain incorrect until you next visit the mailbox.
-- UPDATED: BankItems no longer stores iconpath data or itemcount data if it is 1. This results in roughly 30% reduction in savedvariable size.


-- 14th October 2008, by Xinhuan @ Blackrock US Alliance: Version 30000
-- For use with Live Servers v3.0.2.9056 or WotLK Beta Servers v3.0.2.9061.
-- FIXED: Fix errors resulting from the base UI code being rewritten to use locals and "self" arguments in WotLK.
-- UPDATED: Delay creation of some 600+ child frames and textures (mostly item buttons) until they are shown (saves 50kb). Experimental. May screw up Skinner.
-- UPDATED: Add upgrade function to convert old TBC format links to new WotLK format links.


-- 15th October 2008, by Xinhuan @ Blackrock US Alliance: Version 30001
-- For use with Live Servers v3.0.2.9056 or WotLK Beta Servers v3.0.2.9061.
-- FIXED: Fix errors that appear when opening the Addon options frame.


-- 24th October 2008, by Xinhuan @ Blackrock US Alliance: Version 30002
-- FIXED: Fix errors that occur when used with HealPoints.
-- FIXED: Fix errors that occur when clearing data of a player/guildbank.
-- REMOVED: Removed support for Saeris' Lootlink, which is discontinued and no longer works in patch 3.0.2.


-- 9th June 2009, by Xinhuan @ Blackrock US Alliance: Version 30100
-- FIXED: Fix rare "selfPlayer (nil value)" error.
-- UPDATED: Remove all pre-Wrath compatibility code.
-- UPDATED: Export now exports equipped gear as well.
-- UPDATED: BankItems now uses the WoWAce localization system at http://www.wowace.com/projects/bank-items/localization/
-- UPDATED: Update BankItems tooltip information to work with LinkWrangler's dynamic frame creation.
-- UPDATED: Linking items from BankItems should now behave like the default UI (including being able to link into the AH search box).
-- UPDATED: Significantly reduce string garbage generation. Also some code optimizations.
-- UPDATED: When taking items from the mailbox, the tooltip information is now updated immediately.
-- UPDATED: Add esES localization.
-- NEW: Currency tokens are now recorded.
-- NEW: The contents of the Keyring are now recorded.
-- NEW: Items you have put up for auction are now recorded when you visit the Auction House. These items are not included in searches or tooltips.
-- NEW: Register a LDB launcher if LDB-1.1 is detected during VARIABLES_LOADED.
-- NEW: BankItems will now only show/search characters and guilds from the same faction and realm. You will need to login at least once per character/guild for BankItems to save faction information otherwise these characters will no longer show up unless the "Show/Search All Realms" checkbox is checked.


-- 16 August 2009, by Xinhuan @ Blackrock US Alliance: Version 30200
-- NEW: Added a checkbox to toggle displaying data from the opposite faction (affects both dropdowns and tooltips).
-- UPDATED: Items on the Auction House are now shown in the tooltip information. Note that this information can be inaccurate if these items are sold or expired.


-- 24 December 2009, by Xinhuan @ Blackrock US Alliance: Version 30300
-- FIXED: Ammo will no longer count double when equipped.
-- NEW: Add support for oGlow (github version - http://github.com/haste/oGlow, not the wowinterface one).


-- 13 October 2010, by Xinhuan @ Barthilas US Alliance: Version 40000
-- For use with Live Servers v4.0.1.13164 or Cataclysm Beta Servers v4.0.3.13117.
-- FIXED: Fix bug where ammo is not registering as unequipped when you unequip ammo.
-- UPDATED: Items with the same name but with different itemIDs (such as heroic and non-heroic versions of the same item) are now treated as different items in the tooltips.
-- UPDATED: Upgrade all saved data to Cataclysm itemlinks.
-- NEW: Add "/bi open charname" and "/bi charname" command to open the bank of desired character on the same server.


-- 3 July 2011, by Xinhuan @ Barthilas US Alliance: Version 40200
-- For use with Live Servers v4.2.0.14333.
-- FIXED: Fix errors with the export/search result frame's scrolling edit box.
-- UPDATED: Reimplement currency recording.


-- 3 December 2011, by Xinhuan @ Barthilas US Alliance: Version 40300
-- For use with Live Servers v4.3.0.15050.
-- FIXED: Fix errors caused by patch 4.3 when visiting the Auction House.
-- TO BE IMPLEMENTED: Void Storage/Bag search filter.


-- 23 September 2012, by Xinhuan @ Barthilas US Alliance: Version 50001
-- For use with Live Servers v5.0.5.16057.
-- UPDATED: Upgrade all saved data to new itemlinks format.
-- FIXED: Remove Keyring and ranged slot + ammo (thanks iceeagle).
-- NEW: Add ptBR and itIT localizations.


-- 7 October 2012, by Xinhuan @ Frostmourne US Alliance: Version 50002
-- For use with Live Servers v5.0.5.16057.
-- UPDATED: Add workaround for crash problems with the game client if the user has taint log enabled.
-- NEW: Added Void Storage support (thanks cybermind)
-- FIXED: Fix the bug where a 4-slot or smaller sized bag doesn't display the bottom background texture.


-- 13 October 2012, by Xinhuan @ Frostmourne US Alliance: Version 50003
-- For use with Live Servers v5.0.5.16135.
-- FIXED: Fixed incorrect item linking bug introduced in the last update.

-- 30 October 2013, by Kernighan @ Zul'jin US Alliance: Version 50400
-- For use with Live Servers v5.4.1
-- FIXED: Updated TOC
-- FIXED: Updated to use GetRealmName()

-- 18 October 2014
-- For use with Live Server v6.0.2.19034
-- NEW: Support for second Void Storage tab
-- NEW: Support for Reagent Bank
-- UPDATED: Changed layout of additional buttons.
-- REMOVED: Support for oGlow (glowing is now built into WoW)

-- 3 November 2014
-- UPDATED: Use large reagent and guild frames to show those banks
-- ADDED: Alt and Ctrl clicking the LDB feed can now show Guild and Reagent banks
-- ADDED: Crafting from reagent bank will now track inventory decreases
-- ADDED: slash commands now support characters on other realms (character-realm)
-- FIXED: Mailing across realm (character-realm) will track inventory correctly

BankItems_Save           = {}		-- table, SavedVariable, can't be local
BankItems_SaveGuild      = {}		-- table, another SavedVariable
local bankPlayer         = nil		-- table reference
local bankPlayerName     = nil		-- string
local selfPlayer         = nil		-- table reference
local selfPlayerName     = nil		-- string
local selfPlayerRealm    = nil		-- string
local isBankOpen         = false	-- boolean, whether the real bank is open
local isVoidOpen         = false	-- boolean, whether void storage is open
local isGuildBankOpen    = false	-- boolean, whether the real guild bank is open
local mailPage           = 1		-- integer, current page of bag 101
local AHPage             = 1		-- integer, current page of bag 103
local voidPage           = 1		-- integer, current page of bag 104
local voidPageSize       = 18		-- integer, size of pages for bag 104
local reagentBankPage    = 1		-- integer, current page of bag 105 (Reagent Bank)
local reagentBankPageSize= 28		-- integer, size of pages for bag 105 (Reagent Bank)
local BankItems_Quantity = 1		-- integer, used for hooking EnhTooltip data
local KeystoneItemID     = 138019	-- integer, the item id of keystone
local bagsToUpdate       = {}		-- table, stores data about bags to update on next OnUpdate
local mailItem           = {}		-- table, stores data about the item to be mailed
local sortedKeys         = {}		-- table, for sorted player drop-down menu
local sortedGuildKeys    = {}		-- table, for sorted guild drop-down menu
local info               = {}		-- table, for drop-down menu generation
local BankItemsCFrames   = {		-- table, own bag position tracking
	bags      = {},
	bagsShown = 0,
}
local slotAdjust 		= {  		-- table, contains adjustments for finding non-nil values in updated reagent bank and void storage saved variables
	[104] = {},
	[105] = {},
}
BankItems_Cache        = {} -- table, contains a cache of items of every character on the same realm except the player
BankItems_SelfCache    = {} -- table, contains a cache of only the player's items
BankItems_GuildCache   = {} -- table, contains a cache of selected guild's items
BankItems_TooltipCache = {} -- table, contains a cache of tooltip lines that have been added
BankItems_FactionCache = {} -- table, contains a cache of player faction info
BankItems_GFactionCache = {} -- table, contains a cache of guild faction info
local filterSearchText = ""  -- filter text

-- Cataclysm and backwards compatibility
local TOC = select(4, GetBuildInfo())
local MAX_GUILDBANK_TABS = MAX_GUILDBANK_TABS or 8

-- Localization stuff, add a few more entries for convenience
local L = BANKITEMS_LOCALIZATION  -- Localization table
L[" of "] = " "..L["of"].." "

-- Some constants
local BANKITEMS_VERSIONTEXT	= "BankItems v"..GetAddOnMetadata("BankItems", "Version")
local BANKITEMS_BOTTOM_SCREEN_LIMIT	= 80 -- Pixels from bottom not to overlap BankItem bags
local BANKITEMS_UCFA = updateContainerFrameAnchors	-- Remember Blizzard's UCFA for NON-SAFE replacement
local BAGNUMBERS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 100, 101, 102, 103, 104, 105} -- List of bag numbers used internally by BankItems
local NUM_REAGENTBANKGENERIC_SLOTS = 98; --1..98 (14x7) Number of slots in the reagent bank. If Blizzard ever creates a constant, use it instead. They already have NUM_BANKGENERIC_SLOTS
local VOID_STORAGE_MAX = 80;	--Total number of items allowed per Void Storage tab - Same name from Blizzard void storage code in case they make it a global/constant
local VOID_STORAGE_PAGES = 2;	--Total number of Void Storage tabs - Same name from Blizzard void storage code in case they make it a global/constant

local BANKITEMS_UIPANELWINDOWS_TABLE = {area = "left", pushable = 11, whileDead = 1} -- UI Panel layout to be used
local BANKITEMS_INVSLOT = {
	"HEADSLOT",
	"NECKSLOT",
	"SHOULDERSLOT",
	"SHIRTSLOT",
	"CHESTSLOT",
	"WAISTSLOT",
	"LEGSSLOT",
	"FEETSLOT",
	"WRISTSLOT",
	"HANDSSLOT",
	"FINGER0SLOT",
	"FINGER1SLOT",
	"TRINKET0SLOT",
	"TRINKET1SLOT",
	"BACKSLOT",
	"MAINHANDSLOT",
	"SECONDARYHANDSLOT",
	[19] = "TABARDSLOT",
}
local BANKITEMS_BEHAVIORLIST = {
	L["Open bank bags"],
	L["Open inventory bags"],
	L["Open equipped items bag"],
	L["Open mail bag"],
	L["Open currencies bag"],
	L["Open auction house bag"],
	L["Open void storage bag"],
	L["Open reagent bank"],
}
local BANKITEMS_BEHAVIORLIST2 = {
	L["Search bank and bank bags"],
	L["Search inventory bags"],
	L["Search equipped gear"],
	L["Search mailbox"],
	L["Search guild banks"],
}

local ICON_AuctionHouse = "Interface\\Icons\\INV_Hammer_15"; --Wooden mace, supposed to look like an auctioneer gavel. The legacy BankItems AH icon. (what we call bag 103)
local ICON_VoidStorage = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater"; --The icon used by the second tab of Void Storage (what we call bag 104)
local ICON_ReagentBank = "Interface\\Icons\\INV_Enchant_ShardShadowfrostLarge" --old "Interface\\Icons\\INV_Misc_Bag_09_Green"; --Icon for the Reagent Pouch, and the icon we'll use for the reagent bank (what we call bag 105)
local ICON_Mailbox = "Interface\\Icons\\INV_Letter_02.png" --old "Interface\\MailFrame\\Mail-Icon"  --
local ICON_Currency = "Interface\\Icons\\INV_Misc_Coin_01" --old "Interface\\Icons\\Spell_Holy_ChampionsGrace"
local ICON_Equipped_Items = "Interface\\Icons\\INV_Shirt_White_01"

-- Localize some globals
local _G = getfenv(0)
local pairs, ipairs = pairs, ipairs
local tinsert, tremove = tinsert, tremove
local gsub, strfind, strlower, strmatch, strsplit, strtrim = gsub, strfind, strlower, strmatch, strsplit, strtrim
local format = format
local GetContainerItemInfo, GetContainerNumSlots = GetContainerItemInfo, GetContainerNumSlots
local GetInventoryItemLink, GetInventoryItemTexture, GetInventoryItemCount = GetInventoryItemLink, GetInventoryItemTexture, GetInventoryItemCount
local GetMoney = GetMoney
local GetGuildBankTabInfo, GetGuildBankItemInfo, GetGuildBankItemLink = GetGuildBankTabInfo, GetGuildBankItemInfo, GetGuildBankItemLink
local GetInboxHeaderInfo, GetInboxItem, GetInboxItemLink = GetInboxHeaderInfo, GetInboxItem, GetInboxItemLink
local GetItemIcon = GetItemIcon
local GetItemInfo = GetItemInfo
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID;

-- Localize some frame references
local BankItems_Frame
local BankItems_GBFrame
local BankItems_OptionsFrame
local BankItems_ExportFrame
local BankItems_UpdateFrame
local ItemButtonAr = {}
local BagButtonAr = {}
local BagContainerAr = {}
local GBButtonAr = {}
local GBTabFrameAr = {}
local BankItems_RBFrame --Special Reagent Bank Frame
local RBButtonAr = {} --Reagent Bank Buttons
local BankItems_VoidFrame --Special Void Storage Frame
local VoidButtonAr = {} --Void Storage Buttons
local VoidTabFrameAr = {} --Void Storage Tabs

-- For hooking tooltip support
-- LinkWrangler is supported by LinkWrangler callback methods
local TooltipList = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip",
	"ComparisonTooltip",           -- EquipCompare support
	"EQCompareTooltip",            -- EQCompare support
	"tekKompareTooltip",           -- tekKompare support
	"IRR_",
	"LinksTooltip",                -- Links support
	"AtlasLootTooltip",            -- AtlasLoot support
	"ItemMagicTooltip",            -- ItemMagic support
	"SniffTooltip",                -- Sniff support
	"LH_",                         -- LinkHeaven support
	"MirrorTooltip",               -- Mirror support
	"LootLink_ResultsTooltip",     -- Saeris' LootLink support
	"TooltipExchange_TooltipShow", -- TooltipExchange support
}

-- Localize more frames to see if it fixes the Lua interpreter errors on macs
local BankItems_MoneyFrame
local BankItems_MoneyFrameTotal
local BankItems_ShowAllRealms_Check
local BankItems_ShowOppositeFaction_Check
local BankItems_UserDropdown
local BankItems_ExportButton
local BankItems_SearchButton
local BankItems_SearchBox
local BankItems_NextMailButton
local BankItems_PrevMailButton
local BankItems_NextAHButton
local BankItems_PrevAHButton
local BankItems_NextVoidButton
local BankItems_PrevVoidButton
local BankItems_NextReagentButton
local BankItems_PrevReagentButton
local BankItems_GBFrame_MoneyFrame
local BankItems_GuildDropdown
local BankItems_ShowAllRealms_GBCheck
local BankItems_ShowOppositeFaction_GBCheck
local BankItems_GBExportButton
local BankItems_GBEmblemFrame
local BankItems_MinimapButton
local BankItems_OptionsFrame_LockWindow
local BankItems_OptionsFrame_MinimapButton
local BankItems_OptionsFrame_WindowStyle
local BankItems_OptionsFrame_BagParent
local BankItems_OptionsFrame_VoidBag
local BankItems_OptionsFrame_ReagentBag
local BankItems_OptionsFrame_TooltipInfo
local BankItems_GTTDropDown
local BankItems_OptionsFrame_TTSoulbound
local BankItems_BehaviorDropDown
local BankItems_ButtonRadiusSlider
local BankItems_ButtonPosSlider
local BankItems_TransparencySlider
local BankItems_ScaleSlider
local BankItems_ExportFrame_GroupData
local BankItems_ExportFrame_ShowBagPrefix
local BankItems_ExportFrame_SearchDropDown
local BankItems_ExportFrame_SearchTextbox
local BankItems_ExportFrame_SearchAllRealms
local BankItems_ExportFrame_ResetButton
local BankItems_ExportFrame_Scroll
local BankItems_ExportFrame_ScrollText


-------------------------------------------------
-- Constants for the keybindings menu

BINDING_HEADER_BANKITEMS		= L["BankItems Bindings"]
BINDING_NAME_TOGGLEBANKITEMS		= L["Toggle BankItems"]
BINDING_NAME_TOGGLEBANKITEMSALL		= L["Toggle BankItems and all Bags"]
BINDING_NAME_TOGGLEBANKITEMSBANK	= L["Toggle BankItems and all Bank Bags"]
BINDING_NAME_TOGGLEBANKITEMSGUILDBANK	= L["Toggle BankItems Guild Bank"]


-------------------------------------------------
-- OnFoo scripts of the various widgets

function BankItems_Generic_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltiptext, nil, nil, nil, nil, 1)
end

function BankItems_Button_OnEnter(self)
	local t = bankPlayer[self:GetID()]
	if t then
		BankItems_Quantity = t.count or 1
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local link = t.link
		if link:find("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed  = strsplit(":", link)
			local name = string.gsub(string.gsub(link, "^(.*)%[", ""), "%](.*)$", "")
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
		else
			GameTooltip:SetHyperlink(link)
		end
		BankItems_AddEnhTooltip(link, BankItems_Quantity)
		if IsControlKeyDown() then ShowInspectCursor() end
	end
end

function BankItems_Button_OnClick(self, button)
	if bankPlayer[self:GetID()] then
		if IsControlKeyDown() then
			DressUpItemLink(bankPlayer[self:GetID()].link)
		elseif button == "LeftButton" and IsShiftKeyDown() then
			ChatEdit_InsertLink(bankPlayer[self:GetID()].link)
		end
	end
end

function BankItems_Bag_OnEnter(self)
	local id = self:GetID()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if id == 0 then
		GameTooltip:SetText(BACKPACK_TOOLTIP)
	elseif id == 100 then
		GameTooltip:SetText(L["Equipped Items"])
	elseif id == 101 then
		GameTooltip:SetText(L["Items in Mailbox"])
	elseif id == 102 then
		GameTooltip:SetText(CURRENCY)
	elseif id == 103 then
		GameTooltip:SetText(AUCTIONS)
	elseif id == 104 then
		GameTooltip:SetText(VOID_STORAGE)
	elseif id == 105 then
		GameTooltip:SetText(REAGENT_BANK)
	elseif bankPlayer[format("Bag%d", id)] then
		GameTooltip:SetHyperlink(bankPlayer[format("Bag%d", id)].link)--bag item. not need to check battlepet link.
		BankItems_AddEnhTooltip(bankPlayer[format("Bag%d", id)].link, 1)
	end
end

function BankItems_Bag_OnClick(self, button)
	local bagID = self:GetID()
	local theBag = bankPlayer[format("Bag%d", bagID)]
	if bagID == 105 and not BankItems_Save.reagentBags then --use new Reagent Bank Frame
		BankItems_DisplayReagentBank()
	elseif bagID == 104 and not BankItems_Save.voidBags then --use new Void Storage Frame
		BankItems_DisplayVoidStorage()
	else
		if button == "LeftButton" and IsShiftKeyDown() and bagID > 0 and bagID <= 11 then
			ChatEdit_InsertLink(theBag.link)
			return
		end
	
		if not theBag then
			if bagID == 100 then
				BankItems_Chat(L["%s data not found. Please log on this character."]:format(L["Equipped"]))
			elseif bagID == 101 then
				BankItems_Chat(L["Mailbox data not found. Please visit the mailbox on this character."])
			elseif bagID == 102 then
				BankItems_Chat(L["%s data not found. Please log on this character."]:format(CURRENCY))
			elseif bagID == 103 then
				BankItems_Chat(L["%s data not found. Please visit the Auction House on this character."]:format(AUCTIONS))
			elseif bagID == 104 then
				BankItems_Chat(L["%s data not found. Please visit the Void Storage on this character."]:format(VOID_STORAGE))
			elseif bagID == 105 then
				BankItems_Chat(L["%s data not found. Please log on this character."]:format(REAGENT_BANK))
			end
			return
		end
		
		local bagFrame = BagContainerAr[bagID]
		if ( bagFrame:IsVisible() ) then
			bagFrame:Hide()
			return
		end
	
		-- Generate the frame
		local frame = bagFrame
		local size = theBag.size
	
		-- Rest of this code is copied from ContainerFrame.lua, modified slightly for size/links
		local name = frame:GetName();
		local bgTextureTop = _G[name.."BackgroundTop"];
		local bgTextureMiddle = _G[name.."BackgroundMiddle1"];
		local bgTextureMiddle2 = _G[name.."BackgroundMiddle2"];
		local bgTextureBottom = _G[name.."BackgroundBottom"];
		local bgTexture1Slot = _G[name.."Background1Slot"];
		local columns = NUM_CONTAINER_COLUMNS;
		local rows = ceil(size / columns);
		-- if id = 0 then its the backpack
		if ( bagID == 0 ) then
			bgTexture1Slot:Hide();
			--_G[name.."MoneyFrame"]:Show();
			-- Set Backpack texture
			bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
			bgTextureTop:SetHeight(256);
			bgTextureTop:SetTexCoord(0, 1, 0, 1);
			bgTextureTop:Show();
	
			-- Hide unused textures
			for i=1, MAX_BG_TEXTURES do
				_G[name.."BackgroundMiddle"..i]:Hide();
			end
			bgTextureBottom:Hide();
			frame:SetHeight(BACKPACK_HEIGHT);
		else
			if (size == 1) then
				-- Halloween gag gift
				bgTexture1Slot:Show();
				bgTextureTop:Hide();
				bgTextureMiddle:Hide();
				bgTextureMiddle2:Hide();
				bgTextureBottom:Hide();
				--_G[name.."MoneyFrame"]:Hide();
			else
				bgTexture1Slot:Hide();
				bgTextureTop:Show();
	
				-- Not the backpack
				-- Set whether or not its a bank bag
				local bagTextureSuffix = "";
				if ( bagID > NUM_BAG_FRAMES ) then
					bagTextureSuffix = "-Bank";
				elseif ( bagID == KEYRING_CONTAINER ) then
					bagTextureSuffix = "-Keyring";
				end
				
				-- Set textures
				bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
				for i=1, MAX_BG_TEXTURES do
					_G[name.."BackgroundMiddle"..i]:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
					_G[name.."BackgroundMiddle"..i]:Hide();
				end
				bgTextureBottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
				-- Hide the moneyframe since its not the backpack
				--_G[name.."MoneyFrame"]:Hide();
	
				local bgTextureCount, height;
				local rowHeight = 41;
				-- Subtract one, since the top texture contains one row already
				local remainingRows = rows-1;
	
				-- See if the bag needs the texture with two slots at the top
				local isPlusTwoBag;
				if ( mod(size,columns) == 2 ) then
					isPlusTwoBag = 1;
				end
	
				-- Bag background display stuff
				if ( isPlusTwoBag ) then
					bgTextureTop:SetTexCoord(0, 1, 0.189453125, 0.330078125);
					bgTextureTop:SetHeight(72);
				else
					if ( rows == 1 ) then
						-- If only one row chop off the bottom of the texture
						bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.16796875);
						bgTextureTop:SetHeight(86);
					else
						bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.18359375);
						bgTextureTop:SetHeight(94);
					end
				end
				-- Calculate the number of background textures we're going to need
				bgTextureCount = ceil(remainingRows/ROWS_IN_BG_TEXTURE);
	
				local middleBgHeight = 0;
				-- If one row only special case
				if ( rows == 1 ) then
					bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "TOP", 0, 0);
					bgTextureBottom:Show();
					-- Hide middle bg textures
					for i=1, MAX_BG_TEXTURES do
						_G[name.."BackgroundMiddle"..i]:Hide();
					end
				else
					-- Try to cycle all the middle bg textures
					local firstRowPixelOffset = 9;
					local firstRowTexCoordOffset = 0.353515625;
					for i=1, bgTextureCount do
						bgTextureMiddle = _G[name.."BackgroundMiddle"..i];
						if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
							-- If more rows left to draw than can fit in a texture then draw the max possible
							height = ( ROWS_IN_BG_TEXTURE*rowHeight ) + firstRowTexCoordOffset;
							bgTextureMiddle:SetHeight(height);
							bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
							bgTextureMiddle:Show();
							remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
							middleBgHeight = middleBgHeight + height;
						else
							-- If not its a huge bag
							bgTextureMiddle:Show();
							height = remainingRows*rowHeight-firstRowPixelOffset;
							bgTextureMiddle:SetHeight(height);
							bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
							middleBgHeight = middleBgHeight + height;
						end
					end
					-- Position bottom texture
					bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "BOTTOM", 0, 0);
					bgTextureBottom:Show();
				end
				
				-- Set the frame height
				frame:SetHeight(bgTextureTop:GetHeight()+bgTextureBottom:GetHeight()+middleBgHeight);
			end
		end
	
		if (size == 1) then
			-- Halloween gag gift
			frame:SetHeight(70);
			frame:SetWidth(99);
			_G[frame:GetName().."Name"]:SetText("");
			local itemButton = _G[name.."Item1"];
			itemButton:SetID(1);
			itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -10, 5);
			itemButton:Show();
		else
			frame:SetWidth(CONTAINER_WIDTH);
			
			local index, itemButton;
			for i=1, size, 1 do
				index = size - i + 1;
				itemButton = _G[name.."Item"..i];
				itemButton:SetID(index);
				-- Set first button
				if ( i == 1 ) then
					-- Anchor the first item differently if its the backpack frame
					if ( bagID == 0 ) then
						itemButton:SetPoint("BOTTOMRIGHT", name, "TOPRIGHT", -12, -220);
					else
						itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -12, 9);
					end
	
				else
					if ( mod((i-1), columns) == 0 ) then
						itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - columns), "TOPRIGHT", 0, 4);
					else
						itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - 1), "BOTTOMLEFT", -5, 0);
					end
				end
				itemButton:Show();
			end
		end
		for i=size + 1, MAX_CONTAINER_ITEMS, 1 do
			_G[name.."Item"..i]:Hide();
		end
	
		if (bagID == 0) then
			_G[name.."Name"]:SetText(BACKPACK_TOOLTIP)
		elseif (bagID == 100) then
			_G[name.."Name"]:SetText(L["Equipped Items"])
		elseif (bagID == 101) then
			_G[name.."Name"]:SetText(L["Items in Mailbox"])
		elseif (bagID == 102) then
			_G[name.."Name"]:SetText(CURRENCY)
		elseif (bagID == 103) then
			_G[name.."Name"]:SetText(AUCTIONS)
		elseif (bagID == 104) then
			_G[name.."Name"]:SetText(VOID_STORAGE)
		elseif (bagID == 105) then
			_G[name.."Name"]:SetText(REAGENT_BANK)
		else
			_G[name.."Name"]:SetText(BankItems_ParseLink(theBag.link))
		end
		_G[name.."Portrait"]:SetTexture(GetItemIcon(theBag.link) or theBag.icon)
	
		BankItems_PopulateBag(bagID)
		bagFrame:ClearAllPoints()
		if BankItems_Save.BagParent == 1 then
			BankItemsCFrames.bags[BankItemsCFrames.bagsShown + 1] = bagFrame:GetName()
			BankItemsUpdateCFrameAnchors()
		elseif BankItems_Save.BagParent == 2 then
			ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = bagFrame:GetName()
			updateContainerFrameAnchors()
		end
		bagFrame:Show()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		bagFrame:Raise();
	end
end

function BankItems_Bag_OnShow(self)
	BagButtonAr[self:GetID()].HighlightTexture:Show()
	if BankItems_Save.BagParent == 1 then
		BankItemsCFrames.bagsShown = BankItemsCFrames.bagsShown + 1
	elseif BankItems_Save.BagParent == 2 then
		ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1
	end
end

function BankItems_Bag_OnHide(self)
	BagButtonAr[self:GetID()].HighlightTexture:Hide()
	if BankItems_Save.BagParent == 1 then
		BankItemsCFrames.bagsShown = BankItemsCFrames.bagsShown - 1
		tDeleteItem(BankItemsCFrames.bags, self:GetName())	-- defined in UIParent.lua
		BankItemsUpdateCFrameAnchors()
	elseif BankItems_Save.BagParent == 2 then
		ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1
		tDeleteItem(ContainerFrame1.bags, self:GetName())	-- defined in UIParent.lua
		updateContainerFrameAnchors()
	end
	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
end

function BankItems_BagItem_OnEnter(self)
	local bagID = self:GetParent():GetID()
	local itemID = self:GetID()
	if bagID == 101 then
		itemID = itemID + (mailPage - 1) * 18
	elseif bagID == 103 then
		itemID = itemID + (AHPage - 1) * 18
	elseif bagID == 104 then
		itemID = itemID + (voidPage - 1) * voidPageSize
		itemID = slotAdjust[104][itemID] --table listing all non-empty slots
	elseif bagID == 105 then
		itemID = itemID + (reagentBankPage - 1) * reagentBankPageSize
		itemID = slotAdjust[105][itemID] --table listing all non-empty slots
	end
	local item = bankPlayer[format("Bag%d", bagID)][itemID]
	if item then
		local link = item.link
		BankItems_Quantity = item.count or 1
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if type(link) == "number" then
			GameTooltip:SetText(L["Money (cumulative)"])
			SetTooltipMoney(GameTooltip, link)
			SetMoneyFrameColor("GameTooltipMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		else
			if link:find("battlepet") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed  = strsplit(":", link)
				local name = string.gsub(string.gsub(link, "^(.*)%[", ""), "%](.*)$", "")
				BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
			else
				GameTooltip:SetHyperlink(link)
			end
			GameTooltip.BankItemsIsCurrency = strmatch(link, "(currency:%d+)")
			if GameTooltip.BankItemsIsCurrency then
				BankItems_AddTooltipData(GameTooltip)
				GameTooltip.BankItemsIsCurrency = nil
			end
			BankItems_AddEnhTooltip(link, BankItems_Quantity)
			if item.expiry then
				local t = SecondsToTime(item.expiry - time())
				if t == "" then GameTooltip:AddLine(ERR_MAIL_ATTACHMENT_EXPIRED, 0.2890625, 0.6953125, 0.8359375)
				elseif item.deleted then GameTooltip:AddLine(TIME_UNTIL_DELETED..": "..t, 0.2890625, 0.6953125, 0.8359375)
				elseif item.returned then GameTooltip:AddLine(TIME_UNTIL_RETURNED..": "..t, 0.2890625, 0.6953125, 0.8359375)
				end
			end
			if item.AHexpiry then
				local e = item.AHexpiry
				local snaptime = bankPlayer.Bag103.time
				local elapsed = time() - snaptime
				if (e == 1 and elapsed > 30*60) or (e == 2 and elapsed > 2*60*60) or (e == 3 and elapsed > 12*60*60) or (e == 4 and elapsed > 48*60*60) then
					GameTooltip:AddLine(ERR_MAIL_ATTACHMENT_EXPIRED, 0.2890625, 0.6953125, 0.8359375)
				else
					GameTooltip:AddLine(CLOSES_IN..": ".._G[format("AUCTION_TIME_LEFT%d_DETAIL", e)].." "..GUILD_BANK_LOG_TIME:format(SecondsToTime(elapsed)), 0.2890625, 0.6953125, 0.8359375)
				end
			end
		end
		if IsControlKeyDown() then
			ShowInspectCursor()
		end
		GameTooltip:Show()
	elseif bagID == 100 then
		if itemID == 18 then
			-- Tabard fix
			itemID = 19
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(_G[ BANKITEMS_INVSLOT[itemID] ])
		GameTooltip:Show()
	end
end

function BankItems_BagItem_OnClick(self, button)
	local bagID = self:GetParent():GetID()
	local itemID = self:GetID()
	if bagID == 101 then
		itemID = itemID + (mailPage - 1) * 18
	elseif bagID == 103 then
		itemID = itemID + (AHPage - 1) * 18
	elseif bagID == 104 then
		itemID = itemID + (voidPage - 1) * voidPageSize
		itemID = slotAdjust[104][itemID] --table listing all non-empty slots
	elseif bagID == 105 then
		itemID = itemID + (reagentBankPage - 1) * reagentBankPageSize
		itemID = slotAdjust[105][itemID] --table listing all non-empty slots
	end
	local item = bankPlayer[format("Bag%d", bagID)][itemID]
	if item then
		if IsControlKeyDown() then
			if type(item.link) ~= "number" then
				DressUpItemLink(item.link)
			end
		elseif button == "LeftButton" and IsShiftKeyDown() then
			if type(item.link) == "number" then
				ChatEdit_InsertLink(BankItem_ParseMoney(item.link))
			else
				ChatEdit_InsertLink(item.link)
			end
		end
	end
end

function BankItems_BagPortrait_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	local bagNum = self:GetParent():GetID()
	if bagNum == 0 then
		GameTooltip:SetText(BACKPACK_TOOLTIP)
	elseif bagNum == 100 then
		GameTooltip:SetText(L["Equipped Items"])
	elseif bagNum == 101 then
		GameTooltip:SetText(L["Items in Mailbox"])
	elseif bagNum == 102 then
		GameTooltip:SetText(CURRENCY)
	elseif bagNum == 103 then
		GameTooltip:SetText(AUCTIONS)
	elseif bagNum == 104 then
		GameTooltip:SetText(VOID_STORAGE)
	elseif bagNum == 105 then
		GameTooltip:SetText(REAGENT_BANK)
	elseif bankPlayer[format("Bag%d", bagNum)].link then
		GameTooltip:SetHyperlink(bankPlayer[format("Bag%d", bagNum)].link)
		BankItems_AddEnhTooltip(bankPlayer[format("Bag%d", bagNum)].link, 1)
	end
end

function BankItems_AddEnhTooltip(link, quantity)
	if IsAddOnLoaded("EnhTooltip") and EnhTooltip then
		local name = strmatch(link, "|h%[(.-)%]|h|r")
		EnhTooltip.TooltipCall(GameTooltip, name, link, nil, quantity, nil, false, link)
	end
end

function BankItems_Button_OnLeave(self)
	ResetCursor()
	GameTooltip:Hide()
	BattlePetTooltip:Hide()
end

function BankItems_Frame_OnShow(self)
	BankItems_CreateFrames()
	BankItems_Frame:SetUserPlaced(nil)	-- Temporary
	BankItems_PopulateFrame()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
end

function BankItems_Frame_OnHide(self)
	for _, i in ipairs(BAGNUMBERS) do
		if BagContainerAr[i] then
			BagContainerAr[i]:Hide()
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end

function BankItems_Frame_OnDragStart(self)
	self:StartMoving()
	if BankItems_Save.BagParent == 1 then
		self:SetScript("OnUpdate", BankItemsUpdateCFrameAnchors)
	elseif BankItems_Save.BagParent == 2 then
		self:SetScript("OnUpdate", updateContainerFrameAnchors)
	end
end

function BankItems_Frame_OnDragStop(self)
	local _
	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)
	BankItems_Save.pospoint, _, BankItems_Save.posrelpoint, BankItems_Save.posoffsetx, BankItems_Save.posoffsety = BankItems_Frame:GetPoint()
	self:SetUserPlaced(nil)
end

function BankItems_Frame_OnEvent(self, event, ...)
	local arg1 = ...

	if event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		-- Delay updating to the next frame as multiple UNIT_INVENTORY_CHANGED events can occur in 1 frame
		-- This is the reason why BankItemsFu delays updates by 2 frames.
		bagsToUpdate.inv = true
		BankItems_UpdateFrame:SetScript("OnUpdate", BankItems_UpdateFrame_OnUpdate)

	elseif event == "BAG_UPDATE" then
		-- Delay updating to the next frame as multiple BAG_UPDATE events can occur in 1 frame
		-- This is the reason why BankItemsFu delays updates by 2 frames.
		bagsToUpdate[tonumber(arg1)] = true
		BankItems_UpdateFrame:SetScript("OnUpdate", BankItems_UpdateFrame_OnUpdate)

	elseif event == "PLAYER_MONEY" then
		BankItems_SaveMoney()

	elseif event == "MINIMAP_ZONE_CHANGED" or strfind(event, "ZONE_CHANGED") then
		BankItems_SaveZone()

	elseif event == "PLAYER_ENTERING_WORLD" then
		BankItems_SaveInvItems()
		BankItems_SaveMoney()
		BankItems_SaveZone()
		BankItems_SaveFaction()
		BankItems_Generate_SelfItemCache()

	elseif event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
		BankItems_SaveItems()
		BankItems_Generate_SelfItemCache()

	elseif event== "PLAYERREAGENTBANKSLOTS_CHANGED" then --watch for reagent bank updates
		BankItems_SaveReagentBank() --bank doesn't need to be open to read reagent bank contents
		BankItems_Generate_SelfItemCache()
	elseif event == "BANKFRAME_OPENED" then
		isBankOpen = true
		BankItems_SaveItems()
		BankItems_Generate_SelfItemCache()
	elseif event == "BANKFRAME_CLOSED" then
		isBankOpen = false

	elseif event == "MAIL_SHOW" then
		self:RegisterEvent("MAIL_CLOSED")
		if BankItems_Save.TooltipInfo then self:RegisterEvent("MAIL_INBOX_UPDATE") end

	elseif event == "MAIL_INBOX_UPDATE" then
		BankItems_SaveMailbox()
		BankItems_Generate_SelfItemCache()

	elseif event == "MAIL_CLOSED" then
		BankItems_SaveMailbox()
		BankItems_Generate_SelfItemCache()
		self:UnregisterEvent(event)	-- Because it can fire more than once if you walk away from mailbox
		self:UnregisterEvent("MAIL_INBOX_UPDATE")

	elseif event == "MAIL_SEND_SUCCESS" then
		BankItems_Frame_MailSendSuccess()
		BankItems_Generate_ItemCache()
		self:UnregisterEvent(event)

	elseif event == "KNOWN_CURRENCY_TYPES_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" then
		BankItems_SaveCurrency()
		BankItems_Generate_SelfItemCache()

	elseif event == "VOID_STORAGE_CONTENTS_UPDATE" or event == "VOID_TRANSFER_DONE" or event == "VOID_STORAGE_UPDATE" or event == "VOID_STORAGE_OPEN" then
		isVoidOpen = true
		BankItems_SaveVoidStorage()
		BankItems_Generate_SelfItemCache()

	elseif event == "VOID_STORAGE_CLOSE" then
		isVoidOpen = false

	elseif event == "AUCTION_OWNED_LIST_UPDATE" or event == "AUCTION_HOUSE_SHOW" then
		BankItems_SaveAuctions()
		BankItems_Generate_SelfItemCache()

	elseif event == "INVENTORY_SEARCH_UPDATE" then
		BankItems_FilterBags()

	elseif event == "PLAYER_GUILD_UPDATE" then
		BankItems_SaveGuildFaction()

	elseif event == "ADDON_LOADED" and arg1 == "BankItems" then
		BankItems_UpgradeDataToTBC()
		BankItems_UpgradeDataTo24001()
		BankItems_UpgradeDataToWrath()
		BankItems_UpgradeDataToCata()
		BankItems_UpgradeDataToPanda()
		BankItems_Initialize()
		BankItems_Generate_ItemCache()
		self:UnregisterEvent(event)
		BankItems_UpgradeDataToTBC = nil
		BankItems_UpgradeDataTo24001 = nil
		BankItems_UpgradeDataToWrath = nil
		BankItems_UpgradeDataToCata = nil
		BankItems_UpgradeDataToPanda = nil
		BankItems_Initialize = nil

	elseif event == "VARIABLES_LOADED" then
		-- This overrides layout-cache.txt and also ensures all non-LoD addons have already loaded
		BankItems_Initialize2()
		BankItems_Initialize2 = nil

	end
end

function BankItems_UpdateFrame_OnUpdate(self, elapsed)
	for i = 0, 11 do
		if bagsToUpdate[i] then
			BankItems_SaveInvItems(i)
			bagsToUpdate[i] = nil
		end
	end
	if bagsToUpdate.inv then
		BankItems_SaveInvItems("inv")
		bagsToUpdate.inv = nil
	end
	BankItems_Generate_SelfItemCache()
	self:SetScript("OnUpdate", nil)
end
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Generic Handlers for Special Bank Frames
function BankItems_SpecialOnEnter_Handler(self,item) --handles OnEnter functions for Guild Bank, Reagent Bank, and Void Storage buttons
	if item then
		BankItems_Quantity = item.count or 1
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local link = item.link
		if link:find("battlepet") then --6.0 build converts battlepet to normal link, but I leave this code for future use.
			local _, speciesID, level, breedQuality, maxHealth, power, speed  = strsplit(":", link)
			local name = string.gsub(string.gsub(link, "^(.*)%[", ""), "%](.*)$", "")
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
		else
			GameTooltip:SetHyperlink(link)
		end
		BankItems_AddEnhTooltip(link, BankItems_Quantity)
		if IsControlKeyDown() then
			ShowInspectCursor()
		end
	end
end

function BankItems_SpecialOnClick_Handler(item,button) --handles OnClick functions for Guild Bank, Reagent Bank, and Void Storage buttons
	if item then
		if IsControlKeyDown() then
			DressUpItemLink(item.link)
		elseif button == "LeftButton" and IsShiftKeyDown() then
			ChatEdit_InsertLink(item.link)
		end
	end
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Guild Bank Stuff
function BankItems_GBFrame_OnShow()
	BankItems_CreateFrames()
	BankItems_GBFrame:SetUserPlaced(nil)	-- Temporary
	if not BankItems_GuildDropdown.selectedValue then
		-- First time showing, initialize display
		local selfGuildRealm = strtrim(GetRealmName())
		local guild = GetGuildInfo("player")
		if guild then
			-- Player is in a guild
			local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
			if BankItems_SaveGuild[selfGuildName] then
				-- Data exists for this guild
				BankItems_GuildDropdown.selectedValue = selfGuildName
				BankItems_GuildDropdownText:SetText(gsub(selfGuildName, "(.*)|", "<%1>"..L[" of "]))
			end
		end
		if not BankItems_GuildDropdown.selectedValue then
			-- Player is not in a guild, or data doesn't exist for his guild
			-- Select the first guild in sortedGuildKeys
			if #sortedGuildKeys > 0 then
				BankItems_GuildDropdown.selectedValue = sortedGuildKeys[1]
				BankItems_GuildDropdownText:SetText(gsub(sortedGuildKeys[1], "(.*)|", "<%1>"..L[" of "]))
			end
		end
	end

	if BankItems_GuildDropdown.selectedValue then
		-- Display selected guild
		BankItems_PopulateGuildTabs(BankItems_GuildDropdown.selectedValue)
		BankItems_PopulateGuildBank(BankItems_GuildDropdown.selectedValue, BankItems_GBFrame.currentTab)
		BankItems_PopulateGuildTabard(BankItems_GuildDropdown.selectedValue)
		MoneyFrame_Update("BankItems_GBFrame_MoneyFrame", BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue].money)
		BankItems_GBFrame_MoneyFrame:Show()
	else
		-- No guild bank data exists
		BankItems_GBFrame.title:SetText(L["No Guild Bank Data"])
		BankItems_GBFrame.titlebg:SetWidth(BankItems_GBFrame.title:GetWidth()+20)
		for i = 1, 7 do
			BankItems_GBFrame.colbg[i]:Hide()
		end
		for i = 1, 98 do
			GBButtonAr[i]:Hide()
		end
		for i = 1, MAX_GUILDBANK_TABS do
			GBTabFrameAr[i]:Hide()
		end
		BankItems_GBFrame_MoneyFrame:Hide()
		BankItems_GBEmblemFrame:Hide()
		BankItems_GBFrame.currentTab = nil
		BankItems_GBFrame.infotext:SetText(L["You do not have any guild bank data to display."])
		BankItems_GBFrame.infotext:Show()
		BankItems_GuildDropdownText:SetText("")
	end
	PlaySound(SOUNDKIT.GUILD_VAULT_OPEN)
end

function BankItems_GBFrame_OnHide()
	PlaySound(SOUNDKIT.GUILD_VAULT_CLOSE)
end

function BankItems_GBFrame_OnEvent(self, event, ...)
	if event == "GUILDBANKBAGSLOTS_CHANGED" then
		BankItems_SaveGuildBankItems()
		BankItems_Generate_GuildItemCache()

	elseif event == "GUILDBANKFRAME_CLOSED" then
		isGuildBankOpen = false

	elseif event == "GUILDBANKFRAME_OPENED" then
		isGuildBankOpen = true
		BankItems_SaveGuildBankTabard()
		BankItems_SaveGuildBankMoney()
		BankItems_SaveGuildBankTabs()
		-- Don't save items here, data isn't available yet until GUILDBANKBAGSLOTS_CHANGED fires.

	elseif event == "GUILDBANK_UPDATE_MONEY" then
		BankItems_SaveGuildBankMoney()

	elseif event == "GUILDBANK_UPDATE_TABS" then
		BankItems_SaveGuildBankTabs()

	elseif event == "GUILDTABARD_UPDATE" then
		BankItems_SaveGuildBankTabard()

	elseif event == "VARIABLES_LOADED" then
		BankItems_Generate_GuildItemCache()

	end
end

function BankItems_GuildTabButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue][self:GetID()].name, nil, nil, nil, nil, 1)
end

function BankItems_GuildTabButton_OnClick(self, button)
	BankItems_PopulateGuildBank(BankItems_GuildDropdown.selectedValue, self:GetID())
end

function BankItems_GuildBankItem_OnEnter(self)
	BankItems_SpecialOnEnter_Handler(self, BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue][BankItems_GBFrame.currentTab][self:GetID()])
end

function BankItems_GuildBankItem_OnClick(self, button)
	BankItems_SpecialOnClick_Handler(BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue][BankItems_GBFrame.currentTab][self:GetID()],button)
end

function BankItems_GBFrame_OnDragStart(self)
	self:StartMoving()
end

function BankItems_GBFrame_OnDragStop(self)
	local _
	self:StopMovingOrSizing()
	BankItems_Save.GBpospoint, _, BankItems_Save.GBposrelpoint, BankItems_Save.GBposoffsetx, BankItems_Save.GBposoffsety = BankItems_GBFrame:GetPoint()
	self:SetUserPlaced(nil)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Reagent Bank Stuff
function BankItems_RBFrame_OnShow()
	BankItems_CreateFrames()
	BankItems_RBFrame:SetUserPlaced(nil)	-- Temporary
	BankItems_PopulateReagentBank()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	BagButtonAr[105].HighlightTexture:Show()
end

function BankItems_RBFrame_OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
	BagButtonAr[105].HighlightTexture:Hide()
end

function BankItems_ReagentBankItem_OnEnter(self)
	BankItems_SpecialOnEnter_Handler(self, bankPlayer.Bag105[self:GetID()])
end

function BankItems_ReagentBankItem_OnClick(self, button)
	BankItems_SpecialOnClick_Handler(bankPlayer.Bag105[self:GetID()],button)
end

function BankItems_RBFrame_OnDragStart(self)
	self:StartMoving()
end

function BankItems_RBFrame_OnDragStop(self)
	local _
	self:StopMovingOrSizing()
	BankItems_Save.RBpospoint, _, BankItems_Save.RBposrelpoint, BankItems_Save.RBposoffsetx, BankItems_Save.RBposoffsety = BankItems_RBFrame:GetPoint()
	self:SetUserPlaced(nil)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Void Storage Stuff
function BankItems_VoidFrame_OnShow()
	BankItems_CreateFrames()
	BankItems_VoidFrame:SetUserPlaced(nil)	-- Temporary
	BankItems_PopulateVoidStorage(BankItems_VoidFrame.currentTab)
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	BagButtonAr[104].HighlightTexture:Show()
end

function BankItems_VoidFrame_OnHide()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	BagButtonAr[104].HighlightTexture:Hide()
end

function BankItems_VoidTabButton_OnClick(self, button)
	BankItems_PopulateVoidStorage(self:GetID())
end

function BankItems_VoidStorageItem_OnEnter(self)
	BankItems_SpecialOnEnter_Handler(self, bankPlayer.Bag104[self:GetID() + (BankItems_VoidFrame.currentTab - 1) * VOID_STORAGE_MAX])
end

function BankItems_VoidStorageItem_OnClick(self, button)
	BankItems_SpecialOnClick_Handler(bankPlayer.Bag104[self:GetID() + (BankItems_VoidFrame.currentTab - 1) * VOID_STORAGE_MAX],button)
end


function BankItems_VoidFrame_OnDragStart(self)
	self:StartMoving()
end

function BankItems_VoidFrame_OnDragStop(self)
	local _
	self:StopMovingOrSizing()
	BankItems_Save.Voidpospoint, _, BankItems_Save.Voidposrelpoint, BankItems_Save.Voidposoffsetx, BankItems_Save.Voidposoffsety = BankItems_VoidFrame:GetPoint()
	self:SetUserPlaced(nil)
end

----------------------------------
-- Create frames

-- Create the main BankItems frame
BankItems_Frame = CreateFrame("Frame", "BankItems_Frame", UIParent)
BankItems_Frame:Hide()
BankItems_Frame:EnableMouse(true)
BankItems_Frame:SetToplevel(true)
BankItems_Frame:SetMovable(true)
BankItems_Frame:SetClampedToScreen(true)

-- Create a frame for doing OnUpdates, this isn't used for anything else or shown
-- This is to reduce the number of times BankItems records bag/worn item changes
BankItems_UpdateFrame = CreateFrame("Frame")

-- The BankItems frame
BankItems_Frame:SetScript("OnShow", BankItems_Frame_OnShow)
BankItems_Frame:SetScript("OnHide", BankItems_Frame_OnHide)
BankItems_Frame:SetScript("OnEvent", BankItems_Frame_OnEvent)
BankItems_Frame:SetScript("OnDragStart", BankItems_Frame_OnDragStart)
BankItems_Frame:SetScript("OnDragStop", BankItems_Frame_OnDragStop)
BankItems_Frame:RegisterEvent("ADDON_LOADED")
BankItems_Frame:RegisterEvent("VARIABLES_LOADED")
BankItems_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
BankItems_Frame:RegisterEvent("PLAYER_MONEY")
BankItems_Frame:RegisterEvent("MINIMAP_ZONE_CHANGED")
BankItems_Frame:RegisterEvent("ZONE_CHANGED")
BankItems_Frame:RegisterEvent("ZONE_CHANGED_INDOORS")
BankItems_Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BankItems_Frame:RegisterEvent("BANKFRAME_OPENED")
BankItems_Frame:RegisterEvent("BANKFRAME_CLOSED")
BankItems_Frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
BankItems_Frame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
BankItems_Frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED") --watch for reagent bank updates
BankItems_Frame:RegisterEvent("BAG_UPDATE")
BankItems_Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
BankItems_Frame:RegisterEvent("MAIL_SHOW")
BankItems_Frame:RegisterEvent("MAIL_CLOSED")
BankItems_Frame:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
BankItems_Frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
BankItems_Frame:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE")
BankItems_Frame:RegisterEvent("VOID_TRANSFER_DONE")
BankItems_Frame:RegisterEvent("VOID_STORAGE_UPDATE")
BankItems_Frame:RegisterEvent("VOID_STORAGE_OPEN")
BankItems_Frame:RegisterEvent("VOID_STORAGE_CLOSE")
BankItems_Frame:RegisterEvent("PLAYER_GUILD_UPDATE")
BankItems_Frame:RegisterEvent("AUCTION_HOUSE_SHOW")
BankItems_Frame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
BankItems_Frame:RegisterEvent("INVENTORY_SEARCH_UPDATE")

BankItems_GBFrame = CreateFrame("Frame", "BankItems_GBFrame", UIParent)
BankItems_GBFrame:Hide()
BankItems_GBFrame:EnableMouse(true)
BankItems_GBFrame:SetToplevel(true)
BankItems_GBFrame:SetMovable(true)
BankItems_GBFrame:SetClampedToScreen(true)

BankItems_GBFrame:SetScript("OnShow", BankItems_GBFrame_OnShow)
BankItems_GBFrame:SetScript("OnHide", BankItems_GBFrame_OnHide)
BankItems_GBFrame:SetScript("OnEvent", BankItems_GBFrame_OnEvent)
BankItems_GBFrame:SetScript("OnDragStart", BankItems_GBFrame_OnDragStart)
BankItems_GBFrame:SetScript("OnDragStop", BankItems_GBFrame_OnDragStop)
BankItems_GBFrame:RegisterEvent("VARIABLES_LOADED")
BankItems_GBFrame:RegisterEvent("GUILDBANKFRAME_OPENED")
BankItems_GBFrame:RegisterEvent("GUILDBANKFRAME_CLOSED")
BankItems_GBFrame:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
BankItems_GBFrame:RegisterEvent("GUILDBANK_UPDATE_TABS")
BankItems_GBFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY")
BankItems_GBFrame:RegisterEvent("GUILDTABARD_UPDATE")

BankItems_RBFrame = CreateFrame("Frame", "BankItems_RBFrame", UIParent, "BasicFrameTemplate")
BankItems_RBFrame:Hide()
BankItems_RBFrame:EnableMouse(true)
BankItems_RBFrame:SetToplevel(true)
BankItems_RBFrame:SetMovable(true)
BankItems_RBFrame:SetClampedToScreen(true)

BankItems_RBFrame:SetScript("OnShow", BankItems_RBFrame_OnShow)
BankItems_RBFrame:SetScript("OnHide", BankItems_RBFrame_OnHide)
BankItems_RBFrame:SetScript("OnDragStart", BankItems_RBFrame_OnDragStart)
BankItems_RBFrame:SetScript("OnDragStop", BankItems_RBFrame_OnDragStop)

BankItems_VoidFrame = CreateFrame("Frame", "BankItems_VoidFrame", UIParent, "BasicFrameTemplate")
BankItems_VoidFrame:Hide()
BankItems_VoidFrame:EnableMouse(true)
BankItems_VoidFrame:SetToplevel(true)
BankItems_VoidFrame:SetMovable(true)
BankItems_VoidFrame:SetClampedToScreen(true)

BankItems_VoidFrame:SetScript("OnShow", BankItems_VoidFrame_OnShow)
BankItems_VoidFrame:SetScript("OnHide", BankItems_VoidFrame_OnHide)
BankItems_VoidFrame:SetScript("OnDragStart", BankItems_VoidFrame_OnDragStart)
BankItems_VoidFrame:SetScript("OnDragStop", BankItems_VoidFrame_OnDragStop)

function BankItems_CreateFrames()
	local temp

	-- Portrait
	temp = BankItems_Frame:CreateTexture("BankItems_Portrait", "BACKGROUND")
	temp:SetWidth(60)
	temp:SetHeight(60)
	temp:SetPoint("TOPLEFT", 7, -6)

	-- Frame texture
	temp = BankItems_Frame:CreateTexture(nil, "ARTWORK")
	temp:SetWidth(512)
	temp:SetHeight(512)
	temp:SetPoint("TOPLEFT")
	temp:SetTexture("Interface\\BankFrame\\UI-BankFrame")

	-- Overlay frame texture for inventory/equipped/mail bags
	temp = BankItems_Frame:CreateTexture(nil, "OVERLAY")
	temp:SetTexture("Interface\\BankFrame\\UI-BankFrame")
	do
		local left, right, top, bottom = 37, 374, 197, 248
		temp:SetWidth(right - left)
		temp:SetHeight(bottom - top)
		temp:SetPoint("TOPLEFT", left, -310)
		temp:SetTexCoord(left/512, right/512, top/512, bottom/512)
	end

	-- Title text
	temp = BankItems_Frame:CreateFontString("BankItems_TitleText", "ARTWORK", "GameFontHighlight")
	temp:SetPoint("CENTER", 16, 192)
	temp:SetJustifyH("CENTER")
	-- Version text
	temp = BankItems_Frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	temp:SetWidth(280)
	temp:SetPoint("TOPLEFT", 80, -38)
	temp:SetJustifyH("LEFT")
	temp:SetText(BANKITEMS_VERSIONTEXT)
	-- Item slots text
	temp = BankItems_Frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	temp:SetPoint("CENTER", 3, 155)
	temp:SetText(ITEMSLOTTEXT)
	-- Bag slots text
	temp = BankItems_Frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	temp:SetPoint("CENTER", -20, -45)
	temp:SetText(BAGSLOTTEXT)

	-- Close Button (inherits OnClick script to HideUIPanel(this:GetParent()))
	temp = CreateFrame("Button", "BankItems_CloseButton", BankItems_Frame, "UIPanelCloseButton")
	temp:SetPoint("TOPRIGHT", 0, -8)
	temp:SetScript("OnClick", function()
		HideUIPanel(BankItems_Frame)
		if BankItems_GBFrame:IsVisible() then
			HideUIPanel(BankItems_GBFrame)
		end
		if BankItems_VoidFrame:IsVisible() then
			HideUIPanel(BankItems_VoidFrame)
		end
		if BankItems_RBFrame:IsVisible()  then
			HideUIPanel(BankItems_RBFrame)
		end
	end)

	-- Options Button
	temp = CreateFrame("Button", "BankItems_OptionsButton", BankItems_Frame, "GameMenuButtonTemplate")
	temp:SetWidth(85)
	temp:SetHeight(25)
	temp:SetPoint("TOPRIGHT", -20, -40)
	temp:SetText(L["Options..."])
	temp:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(BANKITEMS_VERSIONTEXT)
	end)

	-- Create the 28 main bank buttons (NUM_BANKGENERIC_SLOTS == 28)
	for i = 1, NUM_BANKGENERIC_SLOTS do
		ItemButtonAr[i] = CreateFrame("Button", "BankItems_Item"..i, BankItems_Frame, "ItemButtonTemplate")
		ItemButtonAr[i]:SetID(i)
		if i == 1 then
			ItemButtonAr[i]:SetPoint("TOPLEFT", 40, -73)
		elseif i % 7 == 1 then
			ItemButtonAr[i]:SetPoint("TOPLEFT", ItemButtonAr[i-7], "BOTTOMLEFT", 0, -7)
		else
			ItemButtonAr[i]:SetPoint("TOPLEFT", ItemButtonAr[i-1], "TOPRIGHT", 12, 0)
		end
		--texture and count keys no longer being used since ItemButtonTemplate already creates local keys ("Count" and "icon")
	end

	-- Create the 14 bag buttons
	for _, i in ipairs(BAGNUMBERS) do
		BagButtonAr[i] = CreateFrame("Button", "BankItems_Bag"..i, BankItems_Frame, "ItemButtonTemplate")
		BagButtonAr[i]:SetID(i)
		BagButtonAr[i].isBag = 1
		BagButtonAr[i].showOverlay = false
		BagButtonAr[i].HighlightTexture = BagButtonAr[i]:CreateTexture(nil, "OVERLAY")
		BagButtonAr[i].HighlightTexture:Hide()
		BagButtonAr[i].HighlightTexture:SetAllPoints(BagButtonAr[i])
		BagButtonAr[i].HighlightTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		BagButtonAr[i].HighlightTexture:SetBlendMode("ADD")
		--texture and count keys no longer being used since ItemButtonTemplate already creates local keys ("Count" and "icon")
	end
	BagButtonAr[5]:SetPoint("TOPLEFT", ItemButtonAr[22], "BOTTOMLEFT", 0, -32)
	BagButtonAr[6]:SetPoint("TOPLEFT", BagButtonAr[5], "TOPRIGHT", 12, 0)
	BagButtonAr[7]:SetPoint("TOPLEFT", BagButtonAr[6], "TOPRIGHT", 12, 0)
	BagButtonAr[8]:SetPoint("TOPLEFT", BagButtonAr[7], "TOPRIGHT", 12, 0)
	BagButtonAr[9]:SetPoint("TOPLEFT", BagButtonAr[8], "TOPRIGHT", 12, 0)
	BagButtonAr[10]:SetPoint("TOPLEFT", BagButtonAr[9], "TOPRIGHT", 12, 0)
	BagButtonAr[11]:SetPoint("TOPLEFT", BagButtonAr[10], "TOPRIGHT", 12, 0)
	BagButtonAr[0]:SetPoint("TOPLEFT", BagButtonAr[11], "BOTTOMLEFT", 0, -7)
	BagButtonAr[1]:SetPoint("TOPRIGHT", BagButtonAr[0], "TOPLEFT", -12, 0)
	BagButtonAr[2]:SetPoint("TOPRIGHT", BagButtonAr[1], "TOPLEFT", -12, 0)
	BagButtonAr[3]:SetPoint("TOPRIGHT", BagButtonAr[2], "TOPLEFT", -12, 0)
	BagButtonAr[4]:SetPoint("TOPRIGHT", BagButtonAr[3], "TOPLEFT", -12, 0)
	BagButtonAr[105]:SetPoint("TOPRIGHT", BagButtonAr[4], "TOPLEFT", -12, 0) --reagent bank
	BagButtonAr[104]:SetPoint("TOPRIGHT", BagButtonAr[105], "TOPLEFT", -12, 0) --void storage

	BagButtonAr[100]:SetScale(0.5) --equipped items
	BagButtonAr[101]:SetScale(0.5) --mailbox
	BagButtonAr[102]:SetScale(0.5) --currencies
	BagButtonAr[103]:SetScale(0.5) --auction house

	BagButtonAr[102]:SetPoint("TOPLEFT", BagButtonAr[5], "TOPLEFT", 0, 47)
	BagButtonAr[100]:SetPoint("TOPLEFT", BagButtonAr[102], "TOPRIGHT", 4, 0)
	BagButtonAr[103]:SetPoint("TOPLEFT", BagButtonAr[100], "TOPRIGHT", 4, 0)
	BagButtonAr[101]:SetPoint("TOPLEFT", BagButtonAr[103], "TOPRIGHT", 4, 0)


	-- Create the Money Total frame
	BankItems_MoneyFrameTotal = CreateFrame("Frame", "BankItems_MoneyFrameTotal", BankItems_Frame, "SmallMoneyFrameTemplate")
	BankItems_MoneyFrameTotal:SetPoint("BOTTOMRIGHT", -8, 21)
	BankItems_MoneyFrameTotal:UnregisterAllEvents()
	BankItems_MoneyFrameTotal:SetScript("OnEvent", nil)
	BankItems_MoneyFrameTotal:SetScript("OnShow", nil)
	BankItems_MoneyFrameTotal.small = 1
	BankItems_MoneyFrameTotal.moneyType = "PLAYER"
	BankItems_MoneyFrameTotal.info = {
		collapse = 1,
		showSmallerCoins = "Backpack"
	}
	BankItems_MoneyFrameTotal:CreateFontString("BankItems_TotalMoneyText", "BACKGROUND", "GameFontHighlightSmall")
	BankItems_TotalMoneyText:SetText("("..L["Total"]..")")
	BankItems_TotalMoneyText:SetJustifyH("LEFT")
	BankItems_TotalMoneyText:SetPoint("RIGHT", "BankItems_MoneyFrameTotal", "LEFT", -3, 0)

	-- Create the 14 bags
	for _, i in ipairs(BAGNUMBERS) do
		local name = "BankItems_ContainerFrame"..i
		BagContainerAr[i] = CreateFrame("Frame", name, UIParent)
		BagContainerAr[i]:SetID(i)
		BagContainerAr[i]:Hide()
		BagContainerAr[i]:EnableMouse(true)
		BagContainerAr[i]:SetToplevel(true)
		BagContainerAr[i]:SetMovable(true)
		BagContainerAr[i]:SetFrameStrata("MEDIUM")
		BagContainerAr[i].portrait = BagContainerAr[i]:CreateTexture(name.."Portrait", "BACKGROUND")
		BagContainerAr[i].portrait:SetWidth(40)
		BagContainerAr[i].portrait:SetHeight(40)
		BagContainerAr[i].portrait:SetPoint("TOPLEFT", 7, -5)
		BagContainerAr[i].backgroundtop = BagContainerAr[i]:CreateTexture(name.."BackgroundTop", "ARTWORK")
		BagContainerAr[i].backgroundtop:SetWidth(256)
		BagContainerAr[i].backgroundtop:SetHeight(512)
		BagContainerAr[i].backgroundtop:SetPoint("TOPRIGHT")
		BagContainerAr[i].backgroundmiddle1 = BagContainerAr[i]:CreateTexture(name.."BackgroundMiddle1", "ARTWORK")
		BagContainerAr[i].backgroundmiddle1:SetWidth(256)
		BagContainerAr[i].backgroundmiddle1:SetHeight(512)
		BagContainerAr[i].backgroundmiddle1:SetPoint("TOP", BagContainerAr[i].backgroundtop, "BOTTOM")
		BagContainerAr[i].backgroundmiddle1:SetTexCoord(0, 1, 0.3515625, 0.8515625)
		BagContainerAr[i].backgroundmiddle2 = BagContainerAr[i]:CreateTexture(name.."BackgroundMiddle2", "ARTWORK")
		BagContainerAr[i].backgroundmiddle2:SetWidth(256)
		BagContainerAr[i].backgroundmiddle2:SetHeight(256)
		BagContainerAr[i].backgroundmiddle2:SetPoint("TOP", BagContainerAr[i].backgroundmiddle1, "BOTTOM")
		BagContainerAr[i].backgroundmiddle2:SetTexCoord(0, 1, 0.353515625, 0.8515625)
		BagContainerAr[i].backgroundbottom = BagContainerAr[i]:CreateTexture(name.."BackgroundBottom", "ARTWORK")
		BagContainerAr[i].backgroundbottom:SetWidth(256)
		BagContainerAr[i].backgroundbottom:SetHeight(10)
		BagContainerAr[i].backgroundbottom:SetTexCoord(0, 1, 0.330078125, 0.349609375)
		BagContainerAr[i].backgroundbottom:SetPoint("TOP", BagContainerAr[i].backgroundmiddle2, "BOTTOM")
		BagContainerAr[i].name = BagContainerAr[i]:CreateFontString(name.."Name", "ARTWORK", "GameFontHighlight")
		BagContainerAr[i].name:SetWidth(112)
		BagContainerAr[i].name:SetHeight(12)
		BagContainerAr[i].name:SetPoint("TOPLEFT", 47, -10)
		BagContainerAr[i].background1Slot = BagContainerAr[i]:CreateTexture(name.."Background1Slot", "ARTWORK")
		BagContainerAr[i].background1Slot:SetWidth(99)
		BagContainerAr[i].background1Slot:SetHeight(74)
		BagContainerAr[i].background1Slot:SetPoint("TOPLEFT", 0, 0)
		BagContainerAr[i].background1Slot:SetTexCoord(0, 0.7734375, 0, 0.578125)
		for j = 1, MAX_CONTAINER_ITEMS do
			BagContainerAr[i][j] = CreateFrame("Button", name.."Item"..j, BagContainerAr[i], "ItemButtonTemplate")
			--BagContainerAr[i][j]:SetID(j)
			if i == 102 then -- currency bag
				BagContainerAr[i][j].Count:SetFontObject(TextStatusBarText)
				BagContainerAr[i][j].Count:SetPoint("BOTTOMRIGHT", 0, 0)
				BagContainerAr[i][j].Count:SetJustifyH("LEFT")
				BagContainerAr[i][j].Count:SetWidth(BagContainerAr[i][j]:GetWidth())
				BagContainerAr[i][j].Count:SetNonSpaceWrap(true)
			end
			--texture and count keys no longer being used since ItemButtonTemplate already creates local keys ("Count" and "icon")
		end
		BagContainerAr[i].PortraitButton = CreateFrame("Button", name.."PortraitButton", BagContainerAr[i])
		BagContainerAr[i].PortraitButton:SetWidth(40)
		BagContainerAr[i].PortraitButton:SetHeight(40)
		BagContainerAr[i].PortraitButton:SetPoint("TOPLEFT", 7, -5)
		BagContainerAr[i].CloseButton = CreateFrame("Button", name.."CloseButton", BagContainerAr[i], "UIPanelCloseButton")
		BagContainerAr[i].CloseButton:SetPoint("TOPRIGHT", 0, -2)
	end

	-- Create the Money frame
	BankItems_MoneyFrame = CreateFrame("Frame", "BankItems_MoneyFrame", BankItems_ContainerFrame0, "SmallMoneyFrameTemplate")
	BankItems_MoneyFrame:SetPoint("BOTTOMRIGHT", -2, 11)
	BankItems_MoneyFrame:UnregisterAllEvents()
	BankItems_MoneyFrame:SetScript("OnEvent", nil)
	BankItems_MoneyFrame:SetScript("OnShow", nil)
	BankItems_MoneyFrame.small = 1
	BankItems_MoneyFrame.moneyType = "PLAYER"
	BankItems_MoneyFrame.info = {
		collapse = 1,
		canPickup = 1,
		showSmallerCoins = "Backpack"
	}

	-- Create the Show All Realms checkbox
	BankItems_ShowAllRealms_Check = CreateFrame("CheckButton", "BankItems_ShowAllRealms_Check", BankItems_Frame, "UICheckButtonTemplate")
	BankItems_ShowAllRealms_Check:SetPoint("BOTTOMLEFT", 30, 40)
	BankItems_ShowAllRealms_Check:SetWidth(16)
	BankItems_ShowAllRealms_Check:SetHeight(16)
	BankItems_ShowAllRealms_Check:SetHitRectInsets(0, -100, 0, 0)
	BankItems_ShowAllRealms_Check:SetChecked(BankItems_Save.ShowAllRealms)
	BankItems_ShowAllRealms_CheckText:SetText(L["Show All Realms"])
	BankItems_ShowAllRealms_Check:SetScript("OnClick", function(self)
		BankItems_Save.ShowAllRealms = self:GetChecked()
		if BankItems_Save.ShowAllRealms then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_Check)
			BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_GBCheck)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_Check)
			BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_GBCheck)
		end
		BankItems_UserDropdownGenerateKeys()
		BankItems_UpdateMoney()
		BankItems_GuildDropdownGenerateKeys()
		CloseDropDownMenus()
		BankItems_ShowAllRealms_GBCheck:SetChecked(BankItems_Save.ShowAllRealms)
		BankItems_Generate_ItemCache()
		BankItems_Generate_GuildItemCache()
	end)

	-- Create the Show Opposite Faction checkbox
	BankItems_ShowOppositeFaction_Check = CreateFrame("CheckButton", "BankItems_ShowOppositeFaction_Check", BankItems_Frame, "UICheckButtonTemplate")
	BankItems_ShowOppositeFaction_Check:SetPoint("BOTTOMLEFT", 30, 54)
	BankItems_ShowOppositeFaction_Check:SetWidth(16)
	BankItems_ShowOppositeFaction_Check:SetHeight(16)
	BankItems_ShowOppositeFaction_Check:SetHitRectInsets(0, -100, 0, 0)
	BankItems_ShowOppositeFaction_Check:SetChecked(BankItems_Save.ShowOppositeFaction)
	BankItems_ShowOppositeFaction_CheckText:SetText(L["Show Opposite Faction"])
	BankItems_ShowOppositeFaction_Check:SetScript("OnClick", function(self)
		BankItems_Save.ShowOppositeFaction = self:GetChecked()
		if BankItems_Save.ShowOppositeFaction then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		BankItems_UserDropdownGenerateKeys()
		BankItems_UpdateMoney()
		BankItems_GuildDropdownGenerateKeys()
		CloseDropDownMenus()
		BankItems_ShowOppositeFaction_GBCheck:SetChecked(BankItems_Save.ShowOppositeFaction)
		BankItems_Generate_ItemCache()
		BankItems_Generate_GuildItemCache()
	end)

	-- Create the User Dropdown
	BankItems_UserDropdown = CreateFrame("Frame", "BankItems_UserDropdown", BankItems_Frame, "UIDropDownMenuTemplate")
	BankItems_UserDropdown:SetPoint("TOPRIGHT", BankItems_Frame, "BOTTOMRIGHT", -65, 69)
	BankItems_UserDropdown:SetHitRectInsets(16, 16, 0, 0)
	UIDropDownMenu_SetWidth(BankItems_UserDropdown, 140)
	UIDropDownMenu_EnableDropDown(BankItems_UserDropdown)

	-- Create the Export Button
	BankItems_ExportButton = CreateFrame("Button", "BankItems_ExportButton", BankItems_Frame)
	BankItems_ExportButton:SetWidth(32)
	BankItems_ExportButton:SetHeight(32)
	BankItems_ExportButton:SetPoint("TOPRIGHT", BankItems_Frame, "BOTTOMRIGHT", -46, 71)
	BankItems_ExportButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_ExportButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_ExportButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_ExportButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the Search Button
	BankItems_SearchButton = CreateFrame("Button", "BankItems_SearchButton", BankItems_Frame)
	BankItems_SearchButton:SetWidth(32)
	BankItems_SearchButton:SetHeight(32)
	BankItems_SearchButton:SetPoint("TOPRIGHT", BankItems_Frame, "BOTTOMRIGHT", -16, 71)
	BankItems_SearchButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_SearchButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_SearchButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_SearchButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the quick search textbox
	BankItems_SearchBox = CreateFrame("EditBox", "BankItems_SearchBox", BankItems_Frame, "BagSearchBoxTemplate")
	BankItems_SearchBox:SetMaxLetters(15)
	BankItems_SearchBox:SetWidth(130)
	BankItems_SearchBox:SetHeight(20)
	BankItems_SearchBox:SetPoint("TOPRIGHT", -29, -250)
	tinsert(ITEM_SEARCHBAR_LIST, "BankItems_SearchBox")

	-- Create the Next Mail page button in bag 101
	BankItems_NextMailButton = CreateFrame("Button", "BankItems_NextMailButton", BagContainerAr[101])
	BankItems_NextMailButton:SetWidth(32)
	BankItems_NextMailButton:SetHeight(32)
	BankItems_NextMailButton:SetPoint("TOPLEFT", 70, -22)
	BankItems_NextMailButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_NextMailButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_NextMailButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_NextMailButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the Prev Mail page button in bag 101
	BankItems_PrevMailButton = CreateFrame("Button", "BankItems_PrevMailButton", BagContainerAr[101])
	BankItems_PrevMailButton:SetWidth(32)
	BankItems_PrevMailButton:SetHeight(32)
	BankItems_PrevMailButton:SetPoint("TOPLEFT", 45, -22)
	BankItems_PrevMailButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	BankItems_PrevMailButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	BankItems_PrevMailButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	BankItems_PrevMailButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the mail text in bag 101
	BagContainerAr[101].mailtext = BagContainerAr[101]:CreateFontString("BankItems_ContainerFrame101_MailText", "ARTWORK", "GameFontHighlight")
	BagContainerAr[101].mailtext:SetPoint("BOTTOMRIGHT", BagContainerAr[101], "TOPLEFT", 95, -64)
	BagContainerAr[101].mailtext:SetText("1-18/18")
	BagContainerAr[101].mailtext:SetJustifyH("RIGHT")

	-- Create the Next AH page button in bag 103
	BankItems_NextAHButton = CreateFrame("Button", "BankItems_NextAHButton", BagContainerAr[103])
	BankItems_NextAHButton:SetWidth(32)
	BankItems_NextAHButton:SetHeight(32)
	BankItems_NextAHButton:SetPoint("TOPLEFT", 70, -22)
	BankItems_NextAHButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_NextAHButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_NextAHButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_NextAHButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the Prev AH page button in bag 103
	BankItems_PrevAHButton = CreateFrame("Button", "BankItems_PrevAHButton", BagContainerAr[103])
	BankItems_PrevAHButton:SetWidth(32)
	BankItems_PrevAHButton:SetHeight(32)
	BankItems_PrevAHButton:SetPoint("TOPLEFT", 45, -22)
	BankItems_PrevAHButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	BankItems_PrevAHButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	BankItems_PrevAHButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	BankItems_PrevAHButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the mail text in bag 103
	BagContainerAr[103].mailtext = BagContainerAr[103]:CreateFontString("BankItems_ContainerFrame103_MailText", "ARTWORK", "GameFontHighlight")
	BagContainerAr[103].mailtext:SetPoint("BOTTOMRIGHT", BagContainerAr[103], "TOPLEFT", 95, -64)
	BagContainerAr[103].mailtext:SetText("1-18/18")
	BagContainerAr[103].mailtext:SetJustifyH("RIGHT")

	-- Create the Next Void page button in bag 104
	BankItems_NextVoidButton = CreateFrame("Button", "BankItems_NextVoidButton", BagContainerAr[104])
	BankItems_NextVoidButton:SetWidth(32)
	BankItems_NextVoidButton:SetHeight(32)
	BankItems_NextVoidButton:SetPoint("TOPLEFT", 70, -22)
	BankItems_NextVoidButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_NextVoidButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_NextVoidButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_NextVoidButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the Prev Void page button in bag 104
	BankItems_PrevVoidButton = CreateFrame("Button", "BankItems_PrevVoidButton", BagContainerAr[104])
	BankItems_PrevVoidButton:SetWidth(32)
	BankItems_PrevVoidButton:SetHeight(32)
	BankItems_PrevVoidButton:SetPoint("TOPLEFT", 45, -22)
	BankItems_PrevVoidButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	BankItems_PrevVoidButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	BankItems_PrevVoidButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	BankItems_PrevVoidButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the mail text in bag 104
	BagContainerAr[104].mailtext = BagContainerAr[104]:CreateFontString("BankItems_ContainerFrame104_MailText", "ARTWORK", "GameFontHighlight")
	BagContainerAr[104].mailtext:SetPoint("BOTTOMRIGHT", BagContainerAr[104], "TOPLEFT", 95, -64)
	BagContainerAr[104].mailtext:SetText("1-18/18")
	BagContainerAr[104].mailtext:SetJustifyH("RIGHT")

	-- Create the Next Reagent page button in bag 105
	BankItems_NextReagentButton = CreateFrame("Button", "BankItems_NextReagentButton", BagContainerAr[105])
	BankItems_NextReagentButton:SetWidth(24)
	BankItems_NextReagentButton:SetHeight(24)
	BankItems_NextReagentButton:SetPoint("TOPLEFT", 160, -26)
	BankItems_NextReagentButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_NextReagentButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_NextReagentButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_NextReagentButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the Prev Reagent page button in bag 105
	BankItems_PrevReagentButton = CreateFrame("Button", "BankItems_PrevReagentButton", BagContainerAr[105])
	BankItems_PrevReagentButton:SetWidth(24)
	BankItems_PrevReagentButton:SetHeight(24)
	BankItems_PrevReagentButton:SetPoint("TOPLEFT", 141, -26)
	BankItems_PrevReagentButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	BankItems_PrevReagentButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	BankItems_PrevReagentButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	BankItems_PrevReagentButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

	-- Create the mail text in bag 105
	BagContainerAr[105].mailtext = BagContainerAr[105]:CreateFontString("BankItems_ContainerFrame105_MailText", "ARTWORK", "GameFontHighlight")
	BagContainerAr[105].mailtext:SetPoint("BOTTOMRIGHT", BagContainerAr[105], "TOPLEFT", 140, -44)
	BagContainerAr[105].mailtext:SetText(format("1-%d of %d", reagentBankPageSize, NUM_REAGENTBANKGENERIC_SLOTS))
	BagContainerAr[105].mailtext:SetJustifyH("RIGHT")
	--Guild Bank
	-- Title Background
	BankItems_GBFrame.titlebg = BankItems_GBFrame:CreateTexture(nil, "OVERLAY")
	BankItems_GBFrame.titlebg:SetWidth(10)
	BankItems_GBFrame.titlebg:SetHeight(18)
	BankItems_GBFrame.titlebg:SetPoint("TOP", 61, -43)
	BankItems_GBFrame.titlebg:SetTexture("Interface\\GuildBankFrame\\UI-TabNameBorder")
	BankItems_GBFrame.titlebg:SetTexCoord(0.0625, 0.546875, 0, 0.5625)

	-- Title Background Left
	BankItems_GBFrame.titlebgleft = BankItems_GBFrame:CreateTexture(nil, "OVERLAY")
	BankItems_GBFrame.titlebgleft:SetWidth(8)
	BankItems_GBFrame.titlebgleft:SetHeight(18)
	BankItems_GBFrame.titlebgleft:SetPoint("RIGHT", BankItems_GBFrame.titlebg, "LEFT")
	BankItems_GBFrame.titlebgleft:SetTexture("Interface\\GuildBankFrame\\UI-TabNameBorder")
	BankItems_GBFrame.titlebgleft:SetTexCoord(0, 0.0625, 0, 0.5625)

	-- Title Background Right
	BankItems_GBFrame.titlebgright = BankItems_GBFrame:CreateTexture(nil, "OVERLAY")
	BankItems_GBFrame.titlebgright:SetWidth(8)
	BankItems_GBFrame.titlebgright:SetHeight(18)
	BankItems_GBFrame.titlebgright:SetPoint("LEFT", BankItems_GBFrame.titlebg, "RIGHT")
	BankItems_GBFrame.titlebgright:SetTexture("Interface\\GuildBankFrame\\UI-TabNameBorder")
	BankItems_GBFrame.titlebgright:SetTexCoord(0.546875, 0.609375, 0, 0.5625)

	-- Title text
	BankItems_GBFrame.title = BankItems_GBFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BankItems_GBFrame.title:SetPoint("CENTER", BankItems_GBFrame.titlebg, "CENTER", 0, 1)

	-- Left frame background
	BankItems_GBFrame.bgleft = BankItems_GBFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBFrame.bgleft:SetWidth(512)
	BankItems_GBFrame.bgleft:SetHeight(512)
	BankItems_GBFrame.bgleft:SetPoint("TOPLEFT")
	BankItems_GBFrame.bgleft:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-Left")

	-- Right frame background
	BankItems_GBFrame.bgright = BankItems_GBFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBFrame.bgright:SetWidth(512)
	BankItems_GBFrame.bgright:SetHeight(512)
	BankItems_GBFrame.bgright:SetPoint("TOPLEFT", BankItems_GBFrame.bgleft, "TOPRIGHT", 0, -11)
	BankItems_GBFrame.bgright:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-Right")

	-- 7 column backgrounds
	BankItems_GBFrame.colbg = {}
	for i = 1, 7 do
		BankItems_GBFrame.colbg[i] = BankItems_GBFrame:CreateTexture(nil, "ARTWORK")
		BankItems_GBFrame.colbg[i]:SetWidth(100)
		BankItems_GBFrame.colbg[i]:SetHeight(311)
		BankItems_GBFrame.colbg[i]:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-Slots")
		BankItems_GBFrame.colbg[i]:SetTexCoord(0, 0.78125, 0, 0.607421875)
		if i == 1 then
			BankItems_GBFrame.colbg[i]:SetPoint("TOPLEFT", 30, -70)
		else
			BankItems_GBFrame.colbg[i]:SetPoint("TOPLEFT", BankItems_GBFrame.colbg[i-1], "TOPRIGHT", 3, 0)
		end
	end

	-- Info text
	BankItems_GBFrame.infotext = BankItems_GBFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BankItems_GBFrame.infotext:SetPoint("CENTER")
	BankItems_GBFrame.infotext:SetWidth(500)

	-- Create the 98 guild bank buttons
	for i = 1, 98 do
		GBButtonAr[i] = CreateFrame("Button", nil, BankItems_GBFrame, "ItemButtonTemplate") --shouldn't need a global for the button names anymore
		GBButtonAr[i]:SetID(i)
		if i == 1 then
			GBButtonAr[i]:SetPoint("TOPLEFT", 37, -73)
		elseif i % 14 == 1 then
			GBButtonAr[i]:SetPoint("TOPLEFT", GBButtonAr[i-7], "TOPRIGHT", 17, 0)
		elseif i % 14 == 8 then
			GBButtonAr[i]:SetPoint("TOPLEFT", GBButtonAr[i-7], "TOPRIGHT", 12, 0)
		else
			GBButtonAr[i]:SetPoint("TOPLEFT", GBButtonAr[i-1], "BOTTOMLEFT", 0, -7)
		end
		--texture and count keys no longer being used since ItemButtonTemplate already creates local keys ("Count" and "icon")
	end

	-- Create the Money frame
	BankItems_GBFrame_MoneyFrame = CreateFrame("Frame", "BankItems_GBFrame_MoneyFrame", BankItems_GBFrame, "SmallMoneyFrameTemplate")
	BankItems_GBFrame_MoneyFrame:SetPoint("BOTTOMRIGHT", -4, 16)
	BankItems_GBFrame_MoneyFrame:UnregisterAllEvents()
	BankItems_GBFrame_MoneyFrame:SetScript("OnEvent", nil)
	BankItems_GBFrame_MoneyFrame:SetScript("OnShow", nil)
	BankItems_GBFrame_MoneyFrameCopperButton:EnableMouse(false)
	BankItems_GBFrame_MoneyFrameSilverButton:EnableMouse(false)
	BankItems_GBFrame_MoneyFrameGoldButton:EnableMouse(false)
	BankItems_GBFrame_MoneyFrame.small = 1
	BankItems_GBFrame_MoneyFrame.moneyType = "STATIC"
	BankItems_GBFrame_MoneyFrame.info = {
		collapse = 1,
		canPickup = 0,
		showSmallerCoins = "Backpack"
	}
	
	-- Create the tabs
	for i = 1, MAX_GUILDBANK_TABS do
		GBTabFrameAr[i] = CreateFrame("Frame", nil, BankItems_GBFrame)
		GBTabFrameAr[i]:SetWidth(42)
		GBTabFrameAr[i]:SetHeight(50)
		GBTabFrameAr[i]:EnableMouse(true)
		GBTabFrameAr[i].bg = GBTabFrameAr[i]:CreateTexture(nil, "BACKGROUND")
		GBTabFrameAr[i].bg:SetWidth(64)
		GBTabFrameAr[i].bg:SetHeight(64)
		GBTabFrameAr[i].bg:SetPoint("TOPLEFT")
		GBTabFrameAr[i].bg:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-Tab")
		GBTabFrameAr[i].button = CreateFrame("CheckButton", nil, GBTabFrameAr[i])
		GBTabFrameAr[i].button:SetID(i)
		GBTabFrameAr[i].button:SetWidth(36)
		GBTabFrameAr[i].button:SetHeight(34)
		GBTabFrameAr[i].button:SetPoint("TOPLEFT", 2, -8)
		GBTabFrameAr[i].button.texture = GBTabFrameAr[i].button:CreateTexture(nil, "BORDER")
		GBTabFrameAr[i].button.texture:SetAllPoints()
		GBTabFrameAr[i].button.normaltexture = GBTabFrameAr[i].button:CreateTexture()
		GBTabFrameAr[i].button.normaltexture:SetWidth(60)
		GBTabFrameAr[i].button.normaltexture:SetHeight(60)
		GBTabFrameAr[i].button.normaltexture:SetPoint("CENTER", 0, -1)
		GBTabFrameAr[i].button.normaltexture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		GBTabFrameAr[i].button:SetNormalTexture(GBTabFrameAr[i].button.normaltexture)
		GBTabFrameAr[i].button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		GBTabFrameAr[i].button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
		GBTabFrameAr[i].button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		GBTabFrameAr[i].searchOverlay = GBTabFrameAr[i].button:CreateTexture(nil, "OVERLAY")
		GBTabFrameAr[i].searchOverlay:SetAllPoints()
		GBTabFrameAr[i].searchOverlay:SetTexture(0,0,0,0.8)
		GBTabFrameAr[i].showOverlay = false
		if i == 1 then
			GBTabFrameAr[i]:SetPoint("TOPLEFT", BankItems_GBFrame, "TOPRIGHT", -1, -32)
		else
			GBTabFrameAr[i]:SetPoint("TOPLEFT", GBTabFrameAr[i-1], "BOTTOMLEFT", 0, 0)
		end
	end

	-- Close Button (inherits OnClick script to HideUIPanel(this:GetParent()))
	temp = CreateFrame("Button", "BankItems_GBFrame_CloseButton", BankItems_GBFrame, "UIPanelCloseButton")
	temp:SetPoint("TOPRIGHT", 3, -8)

	-- Create the Guild Dropdown
	BankItems_GuildDropdown = CreateFrame("Frame", "BankItems_GuildDropdown", BankItems_GBFrame, "UIDropDownMenuTemplate")
	BankItems_GuildDropdown:SetPoint("TOPLEFT", 8, -38)
	BankItems_GuildDropdown:SetHitRectInsets(16, 16, 0, 0)
	UIDropDownMenu_SetWidth(BankItems_GuildDropdown, 200)
	UIDropDownMenu_EnableDropDown(BankItems_GuildDropdown)

	-- Create the Show All Realms checkbox
	BankItems_ShowAllRealms_GBCheck = CreateFrame("CheckButton", "BankItems_ShowAllRealms_GBCheck", BankItems_GBFrame, "UICheckButtonTemplate")
	BankItems_ShowAllRealms_GBCheck:SetPoint("BOTTOMLEFT", 24, 34)
	BankItems_ShowAllRealms_GBCheck:SetWidth(16)
	BankItems_ShowAllRealms_GBCheck:SetHeight(16)
	BankItems_ShowAllRealms_GBCheck:SetHitRectInsets(0, -100, 0, 0)
	BankItems_ShowAllRealms_GBCheck:SetChecked(BankItems_Save.ShowAllRealms)
	BankItems_ShowAllRealms_GBCheckText:SetText(L["Show All Realms"])
	BankItems_ShowAllRealms_GBCheck:SetScript("OnClick", function(self)
		BankItems_Save.ShowAllRealms = self:GetChecked()
		if BankItems_Save.ShowAllRealms then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_Check)
			BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_GBCheck)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_Check)
			BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_GBCheck)
		end
		BankItems_UserDropdownGenerateKeys()
		BankItems_UpdateMoney()
		BankItems_GuildDropdownGenerateKeys()
		CloseDropDownMenus()
		BankItems_ShowAllRealms_Check:SetChecked(BankItems_Save.ShowAllRealms)
	end)

	-- Create the Show Opposite Faction checkbox
	BankItems_ShowOppositeFaction_GBCheck = CreateFrame("CheckButton", "BankItems_ShowOppositeFaction_GBCheck", BankItems_GBFrame, "UICheckButtonTemplate")
	BankItems_ShowOppositeFaction_GBCheck:SetPoint("BOTTOMLEFT", 24, 45)
	BankItems_ShowOppositeFaction_GBCheck:SetWidth(16)
	BankItems_ShowOppositeFaction_GBCheck:SetHeight(16)
	BankItems_ShowOppositeFaction_GBCheck:SetHitRectInsets(0, -100, 0, 0)
	BankItems_ShowOppositeFaction_GBCheck:SetChecked(BankItems_Save.ShowOppositeFaction)
	BankItems_ShowOppositeFaction_GBCheckText:SetText(L["Show Opposite Faction"])
	BankItems_ShowOppositeFaction_GBCheck:SetScript("OnClick", function(self)
		BankItems_Save.ShowOppositeFaction = self:GetChecked()
		if BankItems_Save.ShowOppositeFaction then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		BankItems_UserDropdownGenerateKeys()
		BankItems_UpdateMoney()
		BankItems_GuildDropdownGenerateKeys()
		CloseDropDownMenus()
		BankItems_ShowOppositeFaction_Check:SetChecked(BankItems_Save.ShowOppositeFaction)
		BankItems_Generate_ItemCache()
		BankItems_Generate_GuildItemCache()
	end)

	--Update Show Opposite Faction checkbox
	if BankItems_Save.ShowAllRealms then
		BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_Check)
		BlizzardOptionsPanel_CheckButton_Disable(BankItems_ShowOppositeFaction_GBCheck)
	else
		BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_Check)
		BlizzardOptionsPanel_CheckButton_Enable(BankItems_ShowOppositeFaction_GBCheck)
	end

	-- Create the Export Button
	BankItems_GBExportButton = CreateFrame("Button", "BankItems_GBExportButton", BankItems_GBFrame)
	BankItems_GBExportButton:SetWidth(32)
	BankItems_GBExportButton:SetHeight(32)
	BankItems_GBExportButton:SetPoint("BOTTOMRIGHT", -15, 32)
	BankItems_GBExportButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	BankItems_GBExportButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	BankItems_GBExportButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	BankItems_GBExportButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	BankItems_GBExportButton.tooltiptext = L["Export BankItems..."]
	BankItems_GBExportButton:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_GBExportButton:SetScript("OnLeave", BankItems_Button_OnLeave)
	BankItems_GBExportButton:SetScript("OnClick", function(self)
		BankItems_GenerateGuildExportText()
		BankItems_ExportFrame:Show()
	end)
	
	-- Create the quick search textbox
	BankItems_GBFrame.Search = CreateFrame("EditBox", "BankItems_GBFrame_SearchBox", BankItems_GBFrame, "BagSearchBoxTemplate")
	BankItems_GBFrame.Search:SetMaxLetters(15)
	BankItems_GBFrame.Search:SetWidth(130)
	BankItems_GBFrame.Search:SetHeight(20)
	BankItems_GBFrame.Search:SetPoint("TOPRIGHT", -15, -43)
	tinsert(ITEM_SEARCHBAR_LIST, "BankItems_GBFrame_SearchBox")
	
	-- Create the tabard frame
	BankItems_GBEmblemFrame = CreateFrame("Frame", "BankItems_GBEmblemFrame", BankItems_GBFrame)
	BankItems_GBEmblemFrame:SetWidth(80)
	BankItems_GBEmblemFrame:SetHeight(60)
	BankItems_GBEmblemFrame:SetPoint("LEFT", BankItems_GuildDropdown, "RIGHT", -40, 6)
	BankItems_GBEmblemFrame:SetScale(0.4)
	BankItems_GBEmblemFrame.bgUL = BankItems_GBEmblemFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBEmblemFrame.bgUL:SetHeight(40)
	BankItems_GBEmblemFrame.bgUL:SetWidth(40)
	BankItems_GBEmblemFrame.bgUL:SetPoint("TOPLEFT")
	BankItems_GBEmblemFrame.bgUL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.bgUR = BankItems_GBEmblemFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBEmblemFrame.bgUR:SetHeight(40)
	BankItems_GBEmblemFrame.bgUR:SetWidth(40)
	BankItems_GBEmblemFrame.bgUR:SetPoint("LEFT", BankItems_GBEmblemFrame.bgUL, "RIGHT")
	BankItems_GBEmblemFrame.bgUR:SetTexCoord(1, 0.5, 0, 1)
	BankItems_GBEmblemFrame.bgBL = BankItems_GBEmblemFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBEmblemFrame.bgBL:SetHeight(20)
	BankItems_GBEmblemFrame.bgBL:SetWidth(40)
	BankItems_GBEmblemFrame.bgBL:SetPoint("TOP", BankItems_GBEmblemFrame.bgUL, "BOTTOM")
	BankItems_GBEmblemFrame.bgBL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.bgBR = BankItems_GBEmblemFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_GBEmblemFrame.bgBR:SetHeight(20)
	BankItems_GBEmblemFrame.bgBR:SetWidth(40)
	BankItems_GBEmblemFrame.bgBR:SetPoint("LEFT", BankItems_GBEmblemFrame.bgBL, "RIGHT")
	BankItems_GBEmblemFrame.bgBR:SetTexCoord(1, 0.5, 0, 1)

	BankItems_GBEmblemFrame.bdUL = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.bdUL:SetHeight(40)
	BankItems_GBEmblemFrame.bdUL:SetWidth(40)
	BankItems_GBEmblemFrame.bdUL:SetPoint("TOPLEFT", BankItems_GBEmblemFrame.bgUL, "TOPLEFT")
	BankItems_GBEmblemFrame.bdUL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.bdUR = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.bdUR:SetHeight(40)
	BankItems_GBEmblemFrame.bdUR:SetWidth(40)
	BankItems_GBEmblemFrame.bdUR:SetPoint("LEFT", BankItems_GBEmblemFrame.bdUL, "RIGHT")
	BankItems_GBEmblemFrame.bdUR:SetTexCoord(1, 0.5, 0, 1)
	BankItems_GBEmblemFrame.bdBL = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.bdBL:SetHeight(20)
	BankItems_GBEmblemFrame.bdBL:SetWidth(40)
	BankItems_GBEmblemFrame.bdBL:SetPoint("TOP", BankItems_GBEmblemFrame.bdUL, "BOTTOM")
	BankItems_GBEmblemFrame.bdBL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.bdBR = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.bdBR:SetHeight(20)
	BankItems_GBEmblemFrame.bdBR:SetWidth(40)
	BankItems_GBEmblemFrame.bdBR:SetPoint("LEFT", BankItems_GBEmblemFrame.bdBL, "RIGHT")
	BankItems_GBEmblemFrame.bdBR:SetTexCoord(1, 0.5, 0, 1)

	BankItems_GBEmblemFrame.UL = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.UL:SetHeight(40)
	BankItems_GBEmblemFrame.UL:SetWidth(40)
	BankItems_GBEmblemFrame.UL:SetPoint("TOPLEFT", BankItems_GBEmblemFrame.bgUL, "TOPLEFT")
	BankItems_GBEmblemFrame.UL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.UR = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.UR:SetHeight(40)
	BankItems_GBEmblemFrame.UR:SetWidth(40)
	BankItems_GBEmblemFrame.UR:SetPoint("LEFT", BankItems_GBEmblemFrame.UL, "RIGHT")
	BankItems_GBEmblemFrame.UR:SetTexCoord(1, 0.5, 0, 1)
	BankItems_GBEmblemFrame.BL = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.BL:SetHeight(20)
	BankItems_GBEmblemFrame.BL:SetWidth(40)
	BankItems_GBEmblemFrame.BL:SetPoint("TOP", BankItems_GBEmblemFrame.UL, "BOTTOM")
	BankItems_GBEmblemFrame.BL:SetTexCoord(0.5, 1, 0, 1)
	BankItems_GBEmblemFrame.BR = BankItems_GBEmblemFrame:CreateTexture(nil, "BORDER")
	BankItems_GBEmblemFrame.BR:SetHeight(20)
	BankItems_GBEmblemFrame.BR:SetWidth(40)
	BankItems_GBEmblemFrame.BR:SetPoint("LEFT", BankItems_GBEmblemFrame.BL, "RIGHT")
	BankItems_GBEmblemFrame.BR:SetTexCoord(1, 0.5, 0, 1)

	--Reagent Bank
	--Background Texture - Created from inherited template so we'll just modify it here
	BankItems_RBFrame.Bg:SetSize(256,256)
	BankItems_RBFrame.Bg:SetPoint("TOPLEFT",0,-20)
	BankItems_RBFrame.Bg:SetPoint("BOTTOMRIGHT")
	BankItems_RBFrame.Bg:SetTexture("Interface\\BankFrame\\Bank-Background",true)
	BankItems_RBFrame.Bg:SetHorizTile(true)
	BankItems_RBFrame.Bg:SetVertTile(true)
	
	-- Title text
	BankItems_RBFrame.TitleText:SetPoint("TOP", -3, -5)

	-- 7 column backgrounds
	BankItems_RBFrame.colbg = {}
	BankItems_RBFrame.colShadow = {}
	for i = 1, 7 do
		BankItems_RBFrame.colbg[i] = BankItems_RBFrame:CreateTexture(nil, "ARTWORK")
		BankItems_RBFrame.colbg[i]:SetSize(100,311)
		BankItems_RBFrame.colbg[i]:SetTexture("Interface\\BankFrame\\Bank")
		BankItems_RBFrame.colbg[i]:SetTexCoord(0.460938,0.851563,0,0.607422)
		if i == 1 then
			BankItems_RBFrame.colbg[i]:SetPoint("TOPLEFT", 15, -50)
		else
			BankItems_RBFrame.colbg[i]:SetPoint("TOPLEFT", BankItems_RBFrame.colbg[i-1], "TOPRIGHT", 3, 0)
		end
		BankItems_RBFrame.colShadow[i] = BankItems_RBFrame:CreateTexture(nil, "BACKGROUND")
		BankItems_RBFrame.colShadow[i]:SetSize(118,329)
		BankItems_RBFrame.colShadow[i]:SetTexture("Interface\\BankFrame\\Bank")
		BankItems_RBFrame.colShadow[i]:SetTexCoord(0,0.460938,0,0.642578)
		BankItems_RBFrame.colShadow[i]:SetPoint("CENTER", BankItems_RBFrame.colbg[i], "CENTER", 0, 0)
	end

	-- Info text
	BankItems_RBFrame.infotext = BankItems_RBFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BankItems_RBFrame.infotext:SetPoint("CENTER")
	BankItems_RBFrame.infotext:SetWidth(500)

	-- Create the 98 reagent bank buttons
	for i = 1, NUM_REAGENTBANKGENERIC_SLOTS do
		RBButtonAr[i] = CreateFrame("Button", nil, BankItems_RBFrame, "ItemButtonTemplate")
		RBButtonAr[i]:SetID(i)
		if i == 1 then
			RBButtonAr[i]:SetPoint("TOPLEFT", 22, -53)
		elseif i % 14 == 1 then
			RBButtonAr[i]:SetPoint("TOPLEFT", RBButtonAr[i-7], "TOPRIGHT", 17, 0)
		elseif i % 14 == 8 then
			RBButtonAr[i]:SetPoint("TOPLEFT", RBButtonAr[i-7], "TOPRIGHT", 12, 0)
		else
			RBButtonAr[i]:SetPoint("TOPLEFT", RBButtonAr[i-1], "BOTTOMLEFT", 0, -7)
		end
	end
	-- Create the quick search textbox
	BankItems_RBFrame.Search = CreateFrame("EditBox", "BankItems_ReagentSearchBox", BankItems_RBFrame, "BagSearchBoxTemplate")
	BankItems_RBFrame.Search:SetMaxLetters(15)
	BankItems_RBFrame.Search:SetWidth(130)
	BankItems_RBFrame.Search:SetHeight(20)
	BankItems_RBFrame.Search:SetPoint("TOPRIGHT", BankItems_RBFrame, -20, -27)
	tinsert(ITEM_SEARCHBAR_LIST, "BankItems_ReagentSearchBox")
	
	
	--Void Storage - Based on Void Storage XML
	-- Background Texture - Created from inherited template so we'll just modify it here
	BankItems_VoidFrame.Bg:SetDrawLayer("BACKGROUND", 1)
	BankItems_VoidFrame.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble",true)
	BankItems_VoidFrame.Bg:SetHorizTile(true)
	BankItems_VoidFrame.Bg:SetVertTile(true)
	-- Color background
	BankItems_VoidFrame.bgTint = BankItems_VoidFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_VoidFrame.bgTint:SetDrawLayer("BACKGROUND", 2)
	BankItems_VoidFrame.bgTint:SetAllPoints()
	BankItems_VoidFrame.bgTint:SetPoint("TOPLEFT",2,-21)
	BankItems_VoidFrame.bgTint:SetPoint("BOTTOMRIGHT",-2,2)
	BankItems_VoidFrame.bgTint:SetTexture(0.302, 0.102, 0.204, 0.5)	
			
	-- Line Art background
	BankItems_VoidFrame.lineArt = BankItems_VoidFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_VoidFrame.lineArt:SetDrawLayer("BACKGROUND", 3)
	BankItems_VoidFrame.lineArt:SetPoint("TOPLEFT",2,-21)
	BankItems_VoidFrame.lineArt:SetPoint("BOTTOMRIGHT",-2,2)
	BankItems_VoidFrame.lineArt:SetTexture("Interface\\Transmogrify\\EtherealLines",true)
	BankItems_VoidFrame.lineArt:SetHorizTile(true)
	BankItems_VoidFrame.lineArt:SetVertTile(true)
	BankItems_VoidFrame.lineArt:SetAlpha(0.3)

	--TopLeft Corner Art
	BankItems_VoidFrame.CornerTL = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.CornerTL:SetDrawLayer("BORDER", -2)
	BankItems_VoidFrame.CornerTL:SetSize(64,64)
	BankItems_VoidFrame.CornerTL:SetPoint("TOPLEFT", -2, -18)
	BankItems_VoidFrame.CornerTL:SetTexture("Interface\\Transmogrify\\Textures")
	BankItems_VoidFrame.CornerTL:SetTexCoord(0.00781250, 0.50781250, 0.00195313, 0.12695313)
	--TopRight Corner Art
	BankItems_VoidFrame.CornerTR = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.CornerTR:SetDrawLayer("BORDER", -2)
	BankItems_VoidFrame.CornerTR:SetSize(64,64)
	BankItems_VoidFrame.CornerTR:SetPoint("TOPRIGHT", 0, -18)
	BankItems_VoidFrame.CornerTR:SetTexture("Interface\\Transmogrify\\Textures")
	BankItems_VoidFrame.CornerTR:SetTexCoord(0.00781250, 0.50781250, 0.38476563, 0.50781250)
	--BottomLeft Corner Art
	BankItems_VoidFrame.CornerBL = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.CornerBL:SetDrawLayer("BORDER", -2)
	BankItems_VoidFrame.CornerBL:SetSize(64,64)
	BankItems_VoidFrame.CornerBL:SetPoint("BOTTOMLEFT", -2, -1)
	BankItems_VoidFrame.CornerBL:SetTexture("Interface\\Transmogrify\\Textures")
	BankItems_VoidFrame.CornerBL:SetTexCoord(0.00781250, 0.50781250, 0.25781250, 0.38085938)
	--BottomRight Corner Art
	BankItems_VoidFrame.CornerBR = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.CornerBR:SetDrawLayer("BORDER", -2)
	BankItems_VoidFrame.CornerBR:SetSize(64,64)
	BankItems_VoidFrame.CornerBR:SetPoint("BOTTOMRIGHT", 0, -1)
	BankItems_VoidFrame.CornerBR:SetTexture("Interface\\Transmogrify\\Textures")
	BankItems_VoidFrame.CornerBR:SetTexCoord(0.00781250, 0.50781250, 0.13085938, 0.25390625)
	--Left Edge
	BankItems_VoidFrame.LeftEdge = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.LeftEdge:SetDrawLayer("BORDER", -3)
	BankItems_VoidFrame.LeftEdge:SetTexture("Interface\\Transmogrify\\VerticalTiles",true)
	BankItems_VoidFrame.LeftEdge:SetSize(23,64)
	BankItems_VoidFrame.LeftEdge:SetPoint("TOPLEFT", BankItems_VoidFrame.CornerTL, "BOTTOMLEFT", 3, 16)
	BankItems_VoidFrame.LeftEdge:SetPoint("BOTTOMLEFT", BankItems_VoidFrame.CornerBL, "TOPLEFT", 3, -16)
	BankItems_VoidFrame.LeftEdge:SetTexCoord(0.40625, 0.765625, 0, 1)
	BankItems_VoidFrame.LeftEdge:SetVertTile(true)
	--Right Edge
	BankItems_VoidFrame.RightEdge = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.RightEdge:SetDrawLayer("BORDER", -3)
	BankItems_VoidFrame.RightEdge:SetTexture("Interface\\Transmogrify\\VerticalTiles",true)
	BankItems_VoidFrame.RightEdge:SetSize(23,64)
	BankItems_VoidFrame.RightEdge:SetPoint("TOPRIGHT", BankItems_VoidFrame.CornerTR, "BOTTOMRIGHT", -3, 16)
	BankItems_VoidFrame.RightEdge:SetPoint("BOTTOMRIGHT", BankItems_VoidFrame.CornerBR, "TOPRIGHT", -3, -16)
	BankItems_VoidFrame.RightEdge:SetTexCoord(0.015625, 0.375, 0, 1)
	BankItems_VoidFrame.RightEdge:SetVertTile(true)
	--Bottom Edge
	BankItems_VoidFrame.BottomEdge = BankItems_VoidFrame:CreateTexture(nil, "BORDER")
	BankItems_VoidFrame.BottomEdge:SetDrawLayer("BORDER", -3)
	BankItems_VoidFrame.BottomEdge:SetTexture("Interface\\Transmogrify\\HorizontalTiles",true)
	BankItems_VoidFrame.BottomEdge:SetSize(64,23)
	BankItems_VoidFrame.BottomEdge:SetPoint("BOTTOMLEFT", BankItems_VoidFrame.CornerBL, "BOTTOMRIGHT", -30, 4)
	BankItems_VoidFrame.BottomEdge:SetPoint("BOTTOMRIGHT", BankItems_VoidFrame.CornerBR, "BOTTOMLEFT", 30, 4)
	BankItems_VoidFrame.BottomEdge:SetTexCoord(0, 1, 0.015625, 0.375)
	BankItems_VoidFrame.BottomEdge:SetHorizTile(true)
	--Top Edge
	BankItems_VoidFrame.TopEdge = BankItems_VoidFrame:CreateTexture(nil, "OVERLAY")
	BankItems_VoidFrame.TopEdge:SetDrawLayer("OVERLAY", -1)
	BankItems_VoidFrame.TopEdge:SetTexture("Interface\\Transmogrify\\HorizontalTiles",true)
	BankItems_VoidFrame.TopEdge:SetSize(64,23)
	BankItems_VoidFrame.TopEdge:SetPoint("TOPLEFT", 2, -3)
	BankItems_VoidFrame.TopEdge:SetPoint("TOPRIGHT", -2, -3)
	BankItems_VoidFrame.TopEdge:SetTexCoord(0, 1, 0.40625, 0.765625)
	BankItems_VoidFrame.TopEdge:SetHorizTile(true)

	-- Info text
	BankItems_VoidFrame.infotext = BankItems_VoidFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BankItems_VoidFrame.infotext:SetPoint("CENTER")
	BankItems_VoidFrame.infotext:SetWidth(501)
	
	BankItems_VoidFrame.StorageFrame = CreateFrame("Frame", nil, BankItems_VoidFrame, "InsetFrameTemplate")
	BankItems_VoidFrame.StorageFrame:SetPoint("TOPLEFT",34,-52)
	BankItems_VoidFrame.StorageFrame:SetPoint("BOTTOMRIGHT",-36,38)
	BankItems_VoidFrame.buttonsBG = BankItems_VoidFrame.StorageFrame:CreateTexture(nil, "BACKGROUND")
	BankItems_VoidFrame.buttonsBG:SetDrawLayer("BACKGROUND", 0)
	BankItems_VoidFrame.buttonsBG:SetAllPoints()
	BankItems_VoidFrame.buttonsBG:SetTexture("Interface\\VoidStorage\\VoidStorage")
	BankItems_VoidFrame.buttonsBG:SetTexCoord(0.00195313, 0.47265625, 0.16601563, 0.50781250)
	-- Title text
	BankItems_VoidFrame.title = BankItems_VoidFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BankItems_VoidFrame.title:SetPoint("BOTTOMLEFT", BankItems_VoidFrame.StorageFrame, "TOPLEFT", 15, 5)
	
	-- Create the 80 void storage buttons
	for i = 1, 80 do
		VoidButtonAr[i] = CreateFrame("Button", nil, BankItems_VoidFrame.StorageFrame, "ItemButtonTemplate")
		VoidButtonAr[i]:SetID(i)
		VoidButtonAr[i].bg = VoidButtonAr[i]:CreateTexture(nil, "BACKGROUND")
		VoidButtonAr[i].bg:SetSize(41,41)
		VoidButtonAr[i].bg:SetPoint("CENTER")
		VoidButtonAr[i].bg:SetTexture("Interface\\VoidStorage\\VoidStorage")
		VoidButtonAr[i].bg:SetTexCoord(0.6640625, 0.74414063, 0.00195313, 0.08203125)
		VoidButtonAr[i]:SetNormalTexture(nil)
		if i == 1 then
			VoidButtonAr[i]:SetPoint("TOPLEFT", 10, -8)
		elseif  i % 8 == 1 then
			if i % 16 == 1 then
				VoidButtonAr[i]:SetPoint("TOPLEFT", VoidButtonAr[i-8], "TOPRIGHT", 14, 0);
			else
				VoidButtonAr[i]:SetPoint("TOPLEFT", VoidButtonAr[i-8], "TOPRIGHT", 7, 0);
			end
		else
			VoidButtonAr[i]:SetPoint("TOPLEFT", VoidButtonAr[i-1], "BOTTOMLEFT", 0, -5);
		end	
	end
	BankItems_VoidFrame.Line1 = BankItems_VoidFrame.StorageFrame:CreateTexture(nil, "ARTWORK")
	BankItems_VoidFrame.Line1:SetSize(2,342)
	BankItems_VoidFrame.Line1:SetTexture(0.1451, 0.0941, 0.1373, 0.8)
	BankItems_VoidFrame.Line1:SetPoint("TOPLEFT", VoidButtonAr[9], "TOPRIGHT", 6, 6)
	
	BankItems_VoidFrame.Line2 = BankItems_VoidFrame.StorageFrame:CreateTexture(nil, "ARTWORK")
	BankItems_VoidFrame.Line2:SetSize(2,342)
	BankItems_VoidFrame.Line2:SetTexture(0.1451, 0.0941, 0.1373, 0.8)
	BankItems_VoidFrame.Line2:SetPoint("TOPLEFT", VoidButtonAr[25], "TOPRIGHT", 6, 6)
	
	BankItems_VoidFrame.Line3 = BankItems_VoidFrame.StorageFrame:CreateTexture(nil, "ARTWORK")
	BankItems_VoidFrame.Line3:SetSize(2,342)
	BankItems_VoidFrame.Line3:SetTexture(0.1451, 0.0941, 0.1373, 0.8)
	BankItems_VoidFrame.Line3:SetPoint("TOPLEFT", VoidButtonAr[41], "TOPRIGHT", 6, 6)
	
	BankItems_VoidFrame.Line4 = BankItems_VoidFrame.StorageFrame:CreateTexture(nil, "ARTWORK")
	BankItems_VoidFrame.Line4:SetSize(2,342)
	BankItems_VoidFrame.Line4:SetTexture(0.1451, 0.0941, 0.1373, 0.8)
	BankItems_VoidFrame.Line4:SetPoint("TOPLEFT", VoidButtonAr[57], "TOPRIGHT", 6, 6)
	
	-- Create the quick search textbox
	BankItems_VoidFrame.Search = CreateFrame("EditBox", "BankItems_VoidSearchBox", BankItems_VoidFrame.StorageFrame, "BagSearchBoxTemplate")
	BankItems_VoidFrame.Search:SetMaxLetters(15)
	BankItems_VoidFrame.Search:SetWidth(130)
	BankItems_VoidFrame.Search:SetHeight(20)
	BankItems_VoidFrame.Search:SetPoint("TOPRIGHT", BankItems_VoidFrame, -50, -28)
	tinsert(ITEM_SEARCHBAR_LIST, "BankItems_VoidSearchBox")
	
	-- Create the tabs
	for i = 1, VOID_STORAGE_PAGES do
		VoidTabFrameAr[i] = CreateFrame("Frame", nil, BankItems_VoidFrame)
		VoidTabFrameAr[i]:SetWidth(42)
		VoidTabFrameAr[i]:SetHeight(50)
		VoidTabFrameAr[i]:EnableMouse(true)
		VoidTabFrameAr[i].bg = VoidTabFrameAr[i]:CreateTexture(nil, "BACKGROUND")
		VoidTabFrameAr[i].bg:SetSize(64,64)
		VoidTabFrameAr[i].bg:SetPoint("TOPLEFT")
		VoidTabFrameAr[i].bg:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
		VoidTabFrameAr[i].button = CreateFrame("CheckButton", nil, VoidTabFrameAr[i])
		VoidTabFrameAr[i].button:SetID(i)
		VoidTabFrameAr[i].button:SetWidth(36)
		VoidTabFrameAr[i].button:SetHeight(34)
		VoidTabFrameAr[i].button:SetPoint("TOPLEFT", 2, -8)
		VoidTabFrameAr[i].button.texture = VoidTabFrameAr[i].button:CreateTexture(nil, "BORDER")
		VoidTabFrameAr[i].button.texture:SetAllPoints()
		VoidTabFrameAr[i].button.normaltexture = VoidTabFrameAr[i].button:CreateTexture()
		VoidTabFrameAr[i].button.normaltexture:SetWidth(60)
		VoidTabFrameAr[i].button.normaltexture:SetHeight(60)
		VoidTabFrameAr[i].button.normaltexture:SetPoint("CENTER", 0, -1)
		VoidTabFrameAr[i].button.normaltexture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		VoidTabFrameAr[i].button:SetNormalTexture(VoidTabFrameAr[i].button.normaltexture)
		VoidTabFrameAr[i].button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		VoidTabFrameAr[i].button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
		VoidTabFrameAr[i].button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		VoidTabFrameAr[i].searchOverlay = VoidTabFrameAr[i].button:CreateTexture(nil, "OVERLAY")
		VoidTabFrameAr[i].searchOverlay:SetAllPoints()
		VoidTabFrameAr[i].searchOverlay:SetTexture(0,0,0,0.8)
		VoidTabFrameAr[i].showOverlay = false
		if i == 1 then
			VoidTabFrameAr[i]:SetPoint("TOPLEFT", BankItems_VoidFrame, "TOPRIGHT", -1, -32)
			VoidTabFrameAr[i].button.texture:SetTexture("Interface\\Icons\\INV_Enchant_EssenceCosmicGreater")
		else
			VoidTabFrameAr[i]:SetPoint("TOPLEFT", VoidTabFrameAr[i-1], "BOTTOMLEFT", 0, 0)
			VoidTabFrameAr[i].button.texture:SetTexture("Interface\\Icons\\INV_Enchant_EssenceArcaneLarge")
		end
	end
	
	-------------------------------------------------
	-- Set scripts of the various widgets
	-- The 28 main bank buttons (NUM_BANKGENERIC_SLOTS == 28)
	for i = 1, NUM_BANKGENERIC_SLOTS do
		ItemButtonAr[i]:SetScript("OnLeave", BankItems_Button_OnLeave)
		ItemButtonAr[i]:SetScript("OnEnter", BankItems_Button_OnEnter)
		ItemButtonAr[i]:SetScript("OnClick", BankItems_Button_OnClick)
	end

	-- The 14 bag buttons
	for _, i in ipairs(BAGNUMBERS) do
		BagButtonAr[i]:SetScript("OnLeave", BankItems_Button_OnLeave)
		BagButtonAr[i]:SetScript("OnEnter", BankItems_Bag_OnEnter)
		BagButtonAr[i]:SetScript("OnClick", BankItems_Bag_OnClick)
	end

	-- The 14 bags
	for _, i in ipairs(BAGNUMBERS) do
		BagContainerAr[i]:SetScript("OnShow", BankItems_Bag_OnShow)
		BagContainerAr[i]:SetScript("OnHide", BankItems_Bag_OnHide)
		for j = 1, MAX_CONTAINER_ITEMS do
			BagContainerAr[i][j]:SetScript("OnLeave", BankItems_Button_OnLeave)
			BagContainerAr[i][j]:SetScript("OnEnter", BankItems_BagItem_OnEnter)
			BagContainerAr[i][j]:SetScript("OnClick", BankItems_BagItem_OnClick)
		end
		BagContainerAr[i].PortraitButton:SetScript("OnEnter", BankItems_BagPortrait_OnEnter)
		BagContainerAr[i].PortraitButton:SetScript("OnLeave", BankItems_Button_OnLeave)
	end

	-- The Show All Realms checkbox
	BankItems_ShowAllRealms_Check.tooltiptext = L["Check to show all saved characters, regardless of realm or faction."]
	BankItems_ShowAllRealms_Check:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_ShowAllRealms_Check:SetScript("OnLeave", BankItems_Button_OnLeave)
	BankItems_ShowAllRealms_GBCheck.tooltiptext = L["Check to show all saved characters, regardless of realm or faction."]
	BankItems_ShowAllRealms_GBCheck:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_ShowAllRealms_GBCheck:SetScript("OnLeave", BankItems_Button_OnLeave)

	-- The Show Opposite Faction checkbox
	BankItems_ShowOppositeFaction_Check.tooltiptext = L["Check to show characters from the opposite faction (includes BankItems tooltips)."]
	BankItems_ShowOppositeFaction_Check:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_ShowOppositeFaction_Check:SetScript("OnLeave", BankItems_Button_OnLeave)
	BankItems_ShowOppositeFaction_GBCheck.tooltiptext = L["Check to show characters from the opposite faction (includes BankItems tooltips)."]
	BankItems_ShowOppositeFaction_GBCheck:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_ShowOppositeFaction_GBCheck:SetScript("OnLeave", BankItems_Button_OnLeave)

	-- The Export Button
	BankItems_ExportButton.tooltiptext = L["Export BankItems..."]
	BankItems_ExportButton:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_ExportButton:SetScript("OnLeave", BankItems_Button_OnLeave)
	BankItems_ExportButton:SetScript("OnClick", function(self)
		BankItems_GenerateExportText()
		BankItems_ExportFrame:Show()
	end)

	-- The Search Button
	BankItems_SearchButton.tooltiptext = L["Search BankItems..."]
	BankItems_SearchButton:SetScript("OnEnter", BankItems_Generic_OnEnter)
	BankItems_SearchButton:SetScript("OnLeave", BankItems_Button_OnLeave)
	BankItems_SearchButton:SetScript("OnClick", BankItems_DisplaySearch)

	-- The Mailbag next button
	BankItems_NextMailButton:SetScript("OnClick", function(self)
		if mailPage * 18 < #bankPlayer.Bag101 then
			mailPage = mailPage + 1
			BankItems_PopulateBag(101)
		end
	end)
	-- The Mailbag prev button
	BankItems_PrevMailButton:SetScript("OnClick", function(self)
		if mailPage > 1 then
			mailPage = mailPage - 1
			BankItems_PopulateBag(101)
		end
	end)

	-- The AH Bag next button
	BankItems_NextAHButton:SetScript("OnClick", function(self)
		if AHPage * 18 < #bankPlayer.Bag103 then
			AHPage = AHPage + 1
			BankItems_PopulateBag(103)
		end
	end)
	-- The AH Bag prev button
	BankItems_PrevAHButton:SetScript("OnClick", function(self)
		if AHPage > 1 then
			AHPage = AHPage - 1
			BankItems_PopulateBag(103)
		end
	end)

	-- The Void Bag next button
	BankItems_NextVoidButton:SetScript("OnClick", function(self)
		if voidPage * voidPageSize < #slotAdjust[104] then
			voidPage = voidPage + 1
			BankItems_PopulateBag(104)
		end
	end)
	-- The Void Bag prev button
	BankItems_PrevVoidButton:SetScript("OnClick", function(self)
		if voidPage > 1 then
			voidPage = voidPage - 1
			BankItems_PopulateBag(104)
		end
	end)

	-- The Reagent Bag next button
	BankItems_NextReagentButton:SetScript("OnClick", function(self)
		if reagentBankPage * reagentBankPageSize < #slotAdjust[105] then --use list of valid items for size since full table has nil entries now
			reagentBankPage = reagentBankPage + 1
			BankItems_PopulateBag(105)
		end
	end)
	-- The Reagent Bag prev button
	BankItems_PrevReagentButton:SetScript("OnClick", function(self)
		if reagentBankPage > 1 then
			reagentBankPage = reagentBankPage - 1
			BankItems_PopulateBag(105)
		end
	end)

	-- Initial player to display self and own guild
	BankItems_SetPlayer(selfPlayerName)

	BankItems_UserDropdownGenerateKeys()
	BankItems_UserDropdown.initialize = BankItems_UserDropdown_Initialize
	BankItems_UserDropdown.selectedValue = selfPlayerName
	BankItems_UserDropdownText:SetText(gsub(selfPlayerName, "|", L[" of "]))

	BankItems_GuildDropdownGenerateKeys()
	BankItems_GuildDropdown.initialize = BankItems_GuildDropdown_Initialize

	for i = 1, MAX_GUILDBANK_TABS do
		GBTabFrameAr[i].button:SetScript("OnLeave", BankItems_Button_OnLeave)
		GBTabFrameAr[i].button:SetScript("OnEnter", BankItems_GuildTabButton_OnEnter)
		GBTabFrameAr[i].button:SetScript("OnClick", BankItems_GuildTabButton_OnClick)
	end
	for i = 1, 98 do
		GBButtonAr[i]:SetScript("OnLeave", BankItems_Button_OnLeave)
		GBButtonAr[i]:SetScript("OnEnter", BankItems_GuildBankItem_OnEnter)
		GBButtonAr[i]:SetScript("OnClick", BankItems_GuildBankItem_OnClick)
	end

	if BankItems_Save.BagParent == 1 then
		for _, i in ipairs(BAGNUMBERS) do
			BagContainerAr[i]:SetScale(BankItems_Save.Scale / 100)
			BagContainerAr[i]:SetAlpha(BankItems_Save.Transparency / 100)
		end
	end

	--Reagent Bank Frame Button Scripts
	for i = 1, 98 do
		RBButtonAr[i]:SetScript("OnLeave", BankItems_Button_OnLeave)
		RBButtonAr[i]:SetScript("OnEnter", BankItems_ReagentBankItem_OnEnter)
		RBButtonAr[i]:SetScript("OnClick", BankItems_ReagentBankItem_OnClick)
	end

	--Void Storage Frame Button/Tab Scripts
	for i = 1, 2 do
		VoidTabFrameAr[i].button:SetScript("OnClick", BankItems_VoidTabButton_OnClick)
	end
	for i = 1, 80 do
		VoidButtonAr[i]:SetScript("OnLeave", BankItems_Button_OnLeave)
		VoidButtonAr[i]:SetScript("OnEnter", BankItems_VoidStorageItem_OnEnter)
		VoidButtonAr[i]:SetScript("OnClick", BankItems_VoidStorageItem_OnClick)
	end

	--Setup slot adjustment table for bag view mode of void storage and reagent bank
	local validCount = 0
	for i = 1, (VOID_STORAGE_PAGES*VOID_STORAGE_MAX) do
		slotAdjust[104][i] = nil
		if bankPlayer.Bag104 and bankPlayer.Bag104[i] then
			validCount = validCount + 1
			slotAdjust[104][validCount] = i
		end
	end
	validCount = 0
	for i = 1, NUM_REAGENTBANKGENERIC_SLOTS do
		slotAdjust[105][i] = nil
		if bankPlayer.Bag105 and bankPlayer.Bag105[i] then
			validCount = validCount + 1
			slotAdjust[105][validCount] = i
		end
	end

	-- Overwrite self to GC
	BankItems_CreateFrames = function() end
end


------------------------------------------------------
-- Utility functions

-- Prints a chat message
function BankItems_Chat(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("<BankItems> "..msg, 1, 1, 0)
	end
end

-- Extracts the itemName out from a full itemLink
function BankItems_ParseLink(link)
	return strmatch(link, "%[(.*)%]") or link
end

-- Returns the string representation of money
function BankItem_ParseMoney(money)
	local g, s, c
	g = floor(money / 10000)
	money = money % 10000
	s = floor(money / 100)
	c = money % 100 % 100
	return format(L["%dg %ds %dc"], g, s, c)
end

function BankItems_GetCoinTextureString(money)
	local g, s, c
	g = floor(money / 10000)
	money = money % 10000
	s = floor(money / 100)
	c = money % 100 % 100
	if g > 0 then
		return GetCoinTextureString(g*10000).." "..GetCoinTextureString(s*100).." "..GetCoinTextureString(c)
	elseif s > 0 then
		return GetCoinTextureString(s*100).." "..GetCoinTextureString(c)
	else
		return GetCoinTextureString(c)
	end
end

-- Table Pool for recycling tables
local tablePool = setmetatable({}, {__mode = "kv"}) -- Weak table

-- Get a new table
local function newTable()
	local t = next(tablePool) or {}
	tablePool[t] = nil
	return t
end

-- Delete table and add to table pool
local function delTable(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			if type(v) == "table" then
				delTable(v) -- child tables get put into the pool
			end
			t[k] = nil
		end
		setmetatable(t, nil)
		t[true] = true
		t[true] = nil
		tablePool[t] = true
	end
	return nil
end


------------------------------------------------------
-- BankItems functions


function BankItems_UpgradeDataToTBC()
	if not BankItems_Save then return end
	if BankItems_Save.Upgraded and BankItems_Save.Upgraded >= 1 then return end

	local bagString
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if value[num] then
					value[num].link = gsub(value[num].link, "item:(%d+):(%d+):(%d+):(%d+)|h", "item:%1:0:0:0:0:0:%3:%4|h")
				end
			end
			for bagNum = 0, 11 do
				bagString = format("Bag%d", bagNum)
				if value[bagString] then
					if bagNum > 0 then
						value[bagString].link = gsub(value[bagString].link, "item:(%d+):(%d+):(%d+):(%d+)|h", "item:%1:0:0:0:0:0:%3:%4|h")
					end
					for bagItem = 1, value[bagString].size do
						if value[bagString][bagItem] then
							value[bagString][bagItem].link = gsub(value[bagString][bagItem].link, "item:(%d+):(%d+):(%d+):(%d+)|h", "item:%1:0:0:0:0:0:%3:%4|h")
						end
					end
				end
			end
		end
	end
	BankItems_Save.Upgraded = 1
end

function BankItems_UpgradeDataTo24001()
	if not BankItems_Save then return end
	if BankItems_Save.Upgraded and BankItems_Save.Upgraded >= 2 then return end

	local bagString
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if value[num] then
					if value[num].link then value[num].icon = nil end
					if value[num].count == 1 then value[num].count = nil end
				end
			end
			for _, bagNum in ipairs(BAGNUMBERS) do
				bagString = format("Bag%d", bagNum)
				if value[bagString] then
					if value[bagString].link then value[bagString].icon = nil end
					for bagItem = 0, max(value[bagString].size, #value[bagString]) do
						if value[bagString][bagItem] then
							if type(value[bagString][bagItem].link) == "string" then value[bagString][bagItem].icon = nil end
							if value[bagString][bagItem].count == 0 then value[bagString][bagItem].count = nil end
							if value[bagString][bagItem].count == 1 then value[bagString][bagItem].count = nil end
							if not next(value[bagString][bagItem]) then
								value[bagString][bagItem] = delTable(value[bagString][bagItem])
							end
						end
					end
				end
			end
		end
	end
	for key, value in pairs(BankItems_SaveGuild) do
		for i = 1, MAX_GUILDBANK_TABS do
			if value[i] then
				for j = 1, 98 do
					if value[i][j] then
						if value[i][j].link then value[i][j].icon = nil end
						if value[i][j].count == 1 then value[i][j].count = nil end
					end
				end
			end
		end
	end
	BankItems_Save.Upgraded = 2
end

function BankItems_UpgradeDataToWrath()
	if not BankItems_Save then return end
	if BankItems_Save.Upgraded and BankItems_Save.Upgraded >= 3 then return end

	local bagString
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if value[num] then
					if value[num].link then
						value[num].link = gsub(value[num].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:70|h")
					end
				end
			end
			for _, bagNum in ipairs(BAGNUMBERS) do
				bagString = format("Bag%d", bagNum)
				if value[bagString] then
					if value[bagString].link then
						value[bagString].link = gsub(value[bagString].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:70|h")
					end
					for bagItem = 0, max(value[bagString].size, #value[bagString]) do
						if value[bagString][bagItem] then
							if type(value[bagString][bagItem].link) == "string" then
								value[bagString][bagItem].link = gsub(value[bagString][bagItem].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:70|h")
							end
						end
					end
				end
			end
		end
	end
	for key, value in pairs(BankItems_SaveGuild) do
		for i = 1, MAX_GUILDBANK_TABS do
			if value[i] then
				for j = 1, 98 do
					if value[i][j] then
						if value[i][j].link then
							value[i][j].link = gsub(value[i][j].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:70|h")
						end
					end
				end
			end
		end
	end
	BankItems_Save.Upgraded = 3
end

function BankItems_UpgradeDataToCata()
	if TOC < 40000 then return end
	if not BankItems_Save then return end
	if BankItems_Save.Upgraded and BankItems_Save.Upgraded >= 4 then return end

	local bagString
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if value[num] then
					if value[num].link then
						value[num].link = gsub(value[num].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:%9:0|h")
					end
				end
			end
			for _, bagNum in ipairs(BAGNUMBERS) do
				bagString = format("Bag%d", bagNum)
				if value[bagString] then
					if value[bagString].link then
						value[bagString].link = gsub(value[bagString].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:%9:0|h")
					end
					for bagItem = 0, max(value[bagString].size, #value[bagString]) do
						if value[bagString][bagItem] then
							if type(value[bagString][bagItem].link) == "string" then
								value[bagString][bagItem].link = gsub(value[bagString][bagItem].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:%9:0|h")
							end
						end
					end
				end
			end
		end
	end
	for key, value in pairs(BankItems_SaveGuild) do
		for i = 1, MAX_GUILDBANK_TABS do
			if value[i] then
				for j = 1, 98 do
					if value[i][j] then
						if value[i][j].link then
							value[i][j].link = gsub(value[i][j].link, "item:(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h", "item:%1:%2:%3:%4:%5:%6:%7:%8:%9:0|h")
						end
					end
				end
			end
		end
	end
	BankItems_Save.Upgraded = 4
end

-- The itemlink format has actually been changed in patch 4.3
function BankItems_UpgradeDataToPanda()
	if TOC < 50001 then return end
	if not BankItems_Save then return end
	if BankItems_Save.Upgraded and BankItems_Save.Upgraded >= 5 then return end

	local bagString
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if value[num] then
					if value[num].link then
						value[num].link = gsub(value[num].link, "item:([-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-)|h%[", "item:%1:0|h[")
					end
				end
			end
			-- Delete keyring data
			value["Bag-2"] = nil
			for _, bagNum in ipairs(BAGNUMBERS) do
				bagString = format("Bag%d", bagNum)
				if value[bagString] then
					if value[bagString].link then
						value[bagString].link = gsub(value[bagString].link, "item:([-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-)|h%[", "item:%1:0|h[")
					end
					for bagItem = 0, max(value[bagString].size, #value[bagString]) do
						if value[bagString][bagItem] then
							if type(value[bagString][bagItem].link) == "string" then
								value[bagString][bagItem].link = gsub(value[bagString][bagItem].link, "item:([-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-)|h%[", "item:%1:0|h[")
							end
						end
					end
					if bagNum == 100 then
						-- Move Tabard in slot 19 to slot 18, if any
						value[bagString][18] = value[bagString][19]
						value[bagString].size = 18
						-- Delete legacy slots if any
						value[bagString][0] = nil
						value[bagString][19] = nil
						value[bagString][20] = nil
					end
				end
			end
		end
	end
	for key, value in pairs(BankItems_SaveGuild) do
		for i = 1, MAX_GUILDBANK_TABS do
			if value[i] then
				for j = 1, 98 do
					if value[i][j] then
						if value[i][j].link then
							value[i][j].link = gsub(value[i][j].link, "item:([-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-)|h%[", "item:%1:0|h[")
						end
					end
				end
			end
		end
	end
	BankItems_Save.Upgraded = 5
end

function BankItems_SlashHandler(message)
	BankItems_CreateFrames()
	message = strtrim(message or "") -- need original case message data for some commands
	local msg = strlower(message)
	local allBags

	if msg == "showbutton" then
		BankItems_Save.ButtonShown = true
		BankItems_MinimapButton_Init()
		return
	elseif msg == "hidebutton" then
		BankItems_Save.ButtonShown = false
		BankItems_MinimapButton_Init()
		return
	elseif strfind(msg, "search (.*)") then
		local searchText = strtrim(strmatch(msg, "search (.*)"))
		local itemMame = strmatch(searchText, "%[(.-)%]")
		if itemMame then searchText = itemMame end
		BankItems_ExportFrame_SearchTextbox:SetText(searchText)
		BankItems_ExportFrame_SearchTextbox:ClearFocus()
		BankItems_Search(searchText)
		BankItems_ExportFrame:Show()
		return
	elseif msg == "clear" then
		if BankItems_Frame:IsVisible() then
			BankItems_DelPlayer(bankPlayerName)
			BankItems_UserDropdown_OnClick(nil, selfPlayerName)
			if bankPlayerName == selfPlayerName then
				BankItems_Generate_SelfItemCache()
			else
				BankItems_Generate_ItemCache()
			end
		end
		return
	elseif msg == "clearall" then
		-- Cannot use this loop to delete yourself because a new table is created
		-- for yourself and results in undefined behavior for this pairs() loop
		for key, value in pairs(BankItems_Save) do
			if type(value) == "table" and key ~= selfPlayerName and key ~= "Behavior" and key ~= "Behavior2" then
				BankItems_DelPlayer(key)
			end
		end
		-- Now delete yourself
		BankItems_DelPlayer(selfPlayerName)
		BankItems_Chat(L["All players' data have been cleared."])
		BankItems_UserDropdown_OnClick(nil, selfPlayerName)
		BankItems_Generate_ItemCache()
		BankItems_Generate_SelfItemCache()
		return
	elseif msg == "all" then
		allBags = 3
	elseif msg == "allbank" then
		allBags = 2
	elseif msg == "" then
		allBags = BankItems_Save.Behavior
	else
		-- Open the bank of specified character
		local p1, p2, p3, p4
		if strfind(msg, "open (.*)") then
			p1, p2 = strmatch(msg, "open (.)(.*)")
		else
			p1, p2 = strmatch(msg, "(.)(.*)")
		end
		if p1 and p2 ~= "" then -- names are at least 2 chars long, second () set returns "" if p1 isn't nil
			message = message:gsub("||","-") -- character name given with char|realm format used by BankItems - using message since realm names can have more than one capital letter
			p3 = strfind(msg, p1)
			p4 = strfind(message, "-") -- character name given with realm
			local playerName = strupper(p1)..p2
			if p4 then -- realm name given
				p1, p2 = strmatch(strsub(message, p4+1), "(.)(.*)") -- correct first letter of realm name not being capitalized but won't work if past the first case mistake
				playerName = strsub(playerName, 1, p4-p3).."|"..strupper(p1)..p2
			else
				playerName = playerName.."|"..selfPlayerRealm
			end
			if BankItems_Save[playerName] then
				ShowUIPanel(BankItems_Frame)
				BankItems_UserDropdown_OnClick(nil, playerName)
				return
			end
		end

		-- Invalid option, show help text
		BankItems_Chat(BANKITEMS_VERSIONTEXT)
		BankItems_Chat(L["Type /bi or /bankitems to open BankItems"])
		BankItems_Chat(L["-- /bi all : open BankItems and all bags"])
		BankItems_Chat(L["-- /bi allbank : open BankItems and all bank bags only"])
		BankItems_Chat(L["-- /bi clear : clear currently selected player's info"])
		BankItems_Chat(L["-- /bi clearall : clear all players' info"])
		BankItems_Chat(L["-- /bi showbutton : show the minimap button"])
		BankItems_Chat(L["-- /bi hidebutton : hide the minimap button"])
		BankItems_Chat(L["-- /bi open charname : open bank of charname on the same server"])
		BankItems_Chat(L["-- /bi charname : open bank of charname on the same server"])
		BankItems_Chat(L["-- /bi search itemname : search for items"])
		BankItems_Chat(L["-- /bis itemname : search for items"])
		BankItems_Chat(L["-- /bigb : open BankItems guild bank"])
		BankItems_Chat(L["-- /bigb clear : clear currently selected guild's info"])
		return
	end

	if BankItems_Frame:IsVisible() then
		HideUIPanel(BankItems_Frame)
		if BankItems_GBFrame:IsVisible() then
			HideUIPanel(BankItems_GBFrame)
		end
		if BankItems_VoidFrame:IsVisible() then
			HideUIPanel(BankItems_VoidFrame)
		end
		if BankItems_RBFrame:IsVisible()  then
			HideUIPanel(BankItems_RBFrame)
		end
	else
		ShowUIPanel(BankItems_Frame)
		if allBags == 3 then
			BankItems_OpenBagsByBehavior(true, true, false, false, false, false, false, false)
		elseif allBags == 2 then
			BankItems_OpenBagsByBehavior(true, false, false, false, false, false, false, false)
		else
			BankItems_OpenBagsByBehavior(unpack(BankItems_Save.Behavior))
		end
	end
end

function BankItems_Initialize()
	-- Set variables about self
	selfPlayerRealm = strtrim(GetRealmName())
	selfPlayerName = UnitName("player").."|"..selfPlayerRealm
	BankItems_Save[selfPlayerName] = BankItems_Save[selfPlayerName] or newTable()
	selfPlayer = BankItems_Save[selfPlayerName]
end

function BankItems_Initialize2()
	if not BankItems_Save.pospoint then
		BankItems_Save.pospoint = "TOPLEFT"
		BankItems_Save.posrelpoint = "TOPLEFT"
		BankItems_Save.posoffsetx = 50
		BankItems_Save.posoffsety = -104
	end
	BankItems_Frame:ClearAllPoints()
	BankItems_Frame:SetWidth(403)
	BankItems_Frame:SetHeight(430)
	BankItems_Frame:SetPoint(BankItems_Save.pospoint, nil, BankItems_Save.posrelpoint, BankItems_Save.posoffsetx, BankItems_Save.posoffsety)
	BankItems_Frame:SetUserPlaced(nil)

	if not BankItems_Save.GBpospoint then
		BankItems_Save.GBpospoint = "TOPLEFT"
		BankItems_Save.GBposrelpoint = "TOPLEFT"
		BankItems_Save.GBposoffsetx = 50
		BankItems_Save.GBposoffsety = -104
	end
	BankItems_GBFrame:ClearAllPoints()
	BankItems_GBFrame:SetWidth(769)
	BankItems_GBFrame:SetHeight(444)
	BankItems_GBFrame:SetPoint(BankItems_Save.GBpospoint, nil, BankItems_Save.GBposrelpoint, BankItems_Save.GBposoffsetx, BankItems_Save.GBposoffsety)
	BankItems_GBFrame:SetUserPlaced(nil)

	if not BankItems_Save.RBpospoint then
		BankItems_Save.RBpospoint = "TOPLEFT"
		BankItems_Save.RBposrelpoint = "TOPLEFT"
		BankItems_Save.RBposoffsetx = 50
		BankItems_Save.RBposoffsety = -104
	end
	BankItems_RBFrame:ClearAllPoints()
	BankItems_RBFrame:SetWidth(748)
	BankItems_RBFrame:SetHeight(376)
	BankItems_RBFrame:SetPoint(BankItems_Save.RBpospoint, nil, BankItems_Save.RBposrelpoint, BankItems_Save.RBposoffsetx, BankItems_Save.RBposoffsety)
	BankItems_RBFrame:SetUserPlaced(nil)
	
	if not BankItems_Save.Voidpospoint then
		BankItems_Save.Voidpospoint = "TOPLEFT"
		BankItems_Save.Voidposrelpoint = "TOPLEFT"
		BankItems_Save.Voidposoffsetx = 50
		BankItems_Save.Voidposoffsety = -104
	end
	BankItems_VoidFrame:ClearAllPoints()
	BankItems_VoidFrame:SetSize(551,436)
	BankItems_VoidFrame:SetPoint(BankItems_Save.Voidpospoint, nil, BankItems_Save.Voidposrelpoint, BankItems_Save.Voidposoffsetx, BankItems_Save.Voidposoffsety)
	BankItems_VoidFrame:SetUserPlaced(nil)

	-- Upgrade behavior
	if type(BankItems_Save.Behavior) == "number" then
		local temp = {false, false, false, false, false, false}
		if BankItems_Save.Behavior == 2 then
			temp[1] = true
		elseif BankItems_Save.Behavior == 3 then
			temp[1] = true
			temp[2] = true
		end
		BankItems_Save.Behavior = temp
	elseif type(BankItems_Save.Behavior) ~= "table" then
		BankItems_Save.Behavior = {false, false, false, false, false, false}
	end

	--Adds a BankItems button to the Feature Frame in Cosmos   -- Isler
	if EarthFeature_AddButton then
		EarthFeature_AddButton(
			{
				id = "BankItems",
				name = L["OfflineBank"],
				subtext = "BankItems",
				tooltip = L["View bank/inventory/mail contents from anywhere!"],
				icon = "Interface\\Buttons\\Button-Backpack-Up",
				callback = BankItems_SlashHandler,
			}
		)
		EarthFeature_AddButton(
			{
				id = "GuildBank",
				name = L["GuildBank"],
				subtext = "GuildBank",
				tooltip = L["View Guild Bank contents from anywhere!"],
				icon = "Interface\\Icons\\INV_Misc_Bag_08",
				callback = BankItems_GBSlashHandler,
			}
		)
	end

	-- LDB launcher
	local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
	if LDB then
		local function TTSort(a, b)
			return BankItems_Save[a].money < BankItems_Save[b].money
		end
		BankItemsLauncher = LDB:NewDataObject("BankItems", {
			type = "launcher",
			icon = "Interface\\Icons\\INV_Misc_Bag_10_Blue",
			OnClick = function(clickedframe, button)
				if IsShiftKeyDown() then
					BankItems_DisplayGuildBank()
				elseif IsAltKeyDown() then
					BankItems_DisplayReagentBank()
				elseif IsControlKeyDown() then
					BankItems_DisplayVoidStorage()
				else
					BankItems_SlashHandler()
				end
			end,
			OnTooltipShow = function(tt)
				tt:AddLine(BANKITEMS_VERSIONTEXT)
				local total = 0
				local realm = "|"..strtrim(GetRealmName())
				local t = newTable()
				for key, value in pairs(BankItems_Save) do
					if type(value) == "table" and strfind(key, realm, 1, true) and (BankItems_Save.ShowOppositeFaction or value.faction == selfPlayer.faction) and value.money then
						tinsert(t, key)
						total = total + value.money
					end
				end
				table.sort(t, TTSort)
				for i = 1, #t do
					tt:AddDoubleLine("|cffffff00"..t[i]:gsub(realm, ""), "|cffffffff"..BankItems_GetCoinTextureString(BankItems_Save[t[i]].money))
				end
				delTable(t)
				tt:AddLine(" ")
				tt:AddDoubleLine("|cffffff00"..L["Total"], "|cffffffff"..BankItems_GetCoinTextureString(total))
				tt:AddLine(L["|cffeda55fClick|r to toggle BankItems"]);
				tt:AddLine(string.format(L["|cffeda55fShift-Click|r to toggle BankItems %s"], GUILD_BANK));
				tt:AddLine(string.format(L["|cffeda55fCtrl-Click|r to toggle BankItems %s"], VOID_STORAGE));
				tt:AddLine(string.format(L["|cffeda55fAlt-Click|r to toggle BankItems %s"], REAGENT_BANK));
			end,
		})
	end
end

function BankItems_SetPlayer(playerName)
	if not BankItems_Save[playerName] then return end
	bankPlayerName = playerName
	bankPlayer = BankItems_Save[playerName]
	mailPage = 1
	AHPage = 1
	voidPage = 1
	reagentBankPage = 1
end

function BankItems_DelPlayer(playerName)
	-- Need to check selfPlayer reference
	if selfPlayer == BankItems_Save[playerName] then
		-- Deleting yourself
		BankItems_Save[playerName] = delTable(BankItems_Save[playerName])
		selfPlayer = nil

		-- Create new table and reassign references to it
		BankItems_Save[selfPlayerName] = newTable()
		selfPlayer = BankItems_Save[selfPlayerName]
		bankPlayer = selfPlayer
		bankPlayerName = selfPlayerName

		-- Save data about self again
		if isBankOpen then
			BankItems_SaveItems()
		end
		if isVoidOpen then
			BankItems_SaveVoidStorage()
		end
		BankItems_SaveInvItems()
		BankItems_SaveMoney()
		BankItems_SaveZone()
		BankItems_SaveFaction()
		BankItems_SaveCurrency()
	else
		-- Deleting someone else
		BankItems_Save[playerName] = delTable(BankItems_Save[playerName])
		BankItems_UserDropdownGenerateKeys()
	end
end

function BankItems_SaveMoney()
	selfPlayer.money = GetMoney()
	if BankItems_Frame:IsVisible() then
		BankItems_UpdateMoney()
	end
end

function BankItems_SaveZone()
	selfPlayer.location = GetRealZoneText()
	if BankItems_Frame:IsVisible() and bankPlayer == selfPlayer then
		BankItems_TitleText:SetText(gsub(bankPlayerName, "|", L[" of "]).." ("..bankPlayer.location..")")
	end
end

function BankItems_SaveFaction()
	selfPlayer.faction = UnitFactionGroup("player")
end

function BankItems_SaveGuildFaction()
	if IsInGuild() and GetGuildInfo("player") then
		local selfGuildRealm = strtrim(GetRealmName())
		local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
		if BankItems_SaveGuild[selfGuildName] then
			BankItems_SaveGuild[selfGuildName].faction = UnitFactionGroup("player")
		end
	end
end

function BankItems_SaveItems()
	if isBankOpen then
		--Read the bank window itself (bagId = BANK_CONTAINER = -1 --> the bank window)
		for num = 1, NUM_BANKGENERIC_SLOTS do
			local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(BANK_CONTAINER, num)
			if link then
				selfPlayer[num] = selfPlayer[num] or newTable()
				selfPlayer[num].count = count and count > 1 and count or nil
				selfPlayer[num].link = link
			else
				selfPlayer[num] = delTable(selfPlayer[num])
			end
		end;

		--Read the contents of each bank bag (bagId = 5..11)
		--ITEM_INVENTORY_BANK_BAG_OFFSET+1 = 5
		--ITEM_INVENTORY_BANK_BAG_OFFSET+NUM_BANKBAGSLOTS = 11
		for bagNum = ITEM_INVENTORY_BANK_BAG_OFFSET+1, ITEM_INVENTORY_BANK_BAG_OFFSET+NUM_BANKBAGSLOTS do
			local bagNum_ID = BankButtonIDToInvSlotID(bagNum, 1)-4		-- BankButtonIDToInvSlotID returns wrong slot IDs for bank bags, -4 to get shifted proper IDs
			local itemLink = GetInventoryItemLink("player", bagNum_ID)
			if itemLink then
				selfPlayer[format("Bag%d", bagNum)] = selfPlayer[format("Bag%d", bagNum)] or newTable()
				local theBag = selfPlayer[format("Bag%d", bagNum)]
				theBag.link = itemLink
				theBag.size = GetContainerNumSlots(bagNum)
				for bagItem = 1, theBag.size do
					local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bagNum, bagItem)
					if link then
						theBag[bagItem] = theBag[bagItem] or newTable()
						theBag[bagItem].link = link
						theBag[bagItem].count = count and count > 1 and count or nil
					else
						theBag[bagItem] = delTable(theBag[bagItem])
					end
				end
			else
				selfPlayer[format("Bag%d", bagNum)] = delTable(selfPlayer[format("Bag%d", bagNum)])
				if bankPlayer == selfPlayer then
					BagContainerAr[bagNum]:Hide()
				end
			end
		end
	end;

	BankItems_SaveReagentBank();

	if BankItems_Frame:IsVisible() and bankPlayer == selfPlayer then
		BankItems_PopulateFrame()
		for i = 5, 11 do
			if BagContainerAr[i]:IsVisible() then
				BankItems_PopulateBag(i)
			end
		end
	end
end

function BankItems_SaveInvItems(bagID)
	-- valid inputs to function: integer indicating bagID to update, or string "inv" to update worn items
	-- or nil to update all bags and worn items
	local startBag, endBag

	-- if bagID is present, only update that bag
	if bagID == "inv" then
		startBag = 1	-- don't record any bags, the loop won't run from 1 to 0
		endBag = 0
	elseif bagID then
		if not isBankOpen and bagID > 4 then
			return		-- Don't update bank bags if bank isn't open
		end
		startBag = bagID
		endBag = bagID
	else
		startBag = -1
		endBag = 4
	end

	selfPlayer["NumBankSlots"] = GetNumBankSlots()
	for bagNum = startBag, endBag do
		local bagString = format("Bag%d", bagNum)

		if bagNum == 0 then
			-- Backpack (bag 0)
			selfPlayer[bagString] = selfPlayer[bagString] or newTable()
			selfPlayer[bagString].link = nil
			selfPlayer[bagString].icon = "Interface\\Buttons\\Button-Backpack-Up"
			selfPlayer[bagString].size = GetContainerNumSlots(bagNum)
		elseif bagNum == -1 then
			-- Main bank area (bag -1) (skip this)
		else
			local bagNum_ID = ContainerIDToInventoryID(bagNum)
			local itemLink = GetInventoryItemLink("player", bagNum_ID)
			if itemLink then
				selfPlayer[bagString] = selfPlayer[bagString] or newTable()
				selfPlayer[bagString].link = itemLink
				selfPlayer[bagString].size = GetContainerNumSlots(bagNum)
			else
				selfPlayer[bagString] = delTable(selfPlayer[bagString])
				if bankPlayer == selfPlayer then
					BagContainerAr[bagNum]:Hide()
				end
			end
		end

		local theBag = selfPlayer[bagString]
		if theBag then
			for bagItem = 1, theBag.size do
				local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bagNum, bagItem)
				if link then
					theBag[bagItem] = theBag[bagItem] or newTable()
					theBag[bagItem].link = link
					theBag[bagItem].count = count and count > 1 and count or nil
				else
					theBag[bagItem] = delTable(theBag[bagItem])
				end
			end
		end

		if bankPlayer == selfPlayer and BagContainerAr[bagNum] and BagContainerAr[bagNum]:IsVisible() then
			BankItems_PopulateBag(bagNum)
		end
	end

	selfPlayer.Bag100 = selfPlayer.Bag100 or newTable()
	if not bagID or bagID == "inv" then
		local theBag = selfPlayer.Bag100
		theBag.link = nil
		theBag.icon = ICON_Equipped_Items
		theBag.size = 18
		for invNum = 1, 18 do
			local realInvNum = invNum
			if invNum == 18 then
				-- Save tabard to slot 18
				realInvNum = 19
			end
			local itemLink = GetInventoryItemLink("player", realInvNum)
			if itemLink then
				theBag[invNum] = theBag[invNum] or newTable()
				theBag[invNum].link = itemLink
				local count = GetInventoryItemCount("player", realInvNum)
				theBag[invNum].count = count and count > 1 and count or nil
			else
				theBag[invNum] = delTable(theBag[invNum])
			end
		end

		if bankPlayer == selfPlayer and BagContainerAr[100] and BagContainerAr[100]:IsVisible() then
			BankItems_PopulateBag(100)
		end
	end

	BankItems_SaveReagentBank()

end

function BankItems_SaveMailbox()
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity
	local name, itemTexture, count, quality, canUse
	local itemPointer
	local numItems = GetInboxNumItems()
	local j = 0
	local moneyTotal = 0

	-- Save mailbox items as bag 101
	selfPlayer.Bag101 = selfPlayer.Bag101 or newTable()
	selfPlayer.Bag101.icon = ICON_Mailbox

	for i = 1, numItems do
		packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity = GetInboxHeaderInfo(i)
		moneyTotal = moneyTotal + money
		if itemCount then
			for k = 1, ATTACHMENTS_MAX_RECEIVE do
				name, itemTexture, count, quality, canUse = GetInboxItem(i, k)
				if name then
					j = j + 1
					selfPlayer.Bag101[j] = selfPlayer.Bag101[j] or newTable()
					itemPointer = selfPlayer.Bag101[j]
					itemPointer.link = GetInboxItemLink(i, k)
					itemPointer.count = count and count > 1 and count or nil
					itemPointer.expiry = time() + floor(daysLeft*60*60*24)
					if InboxItemCanDelete(i) then
						itemPointer.deleted = true
						itemPointer.returned = nil
					else
						itemPointer.deleted = nil
						itemPointer.returned = true
					end
				end
			end
		end
	end
	if moneyTotal > 0 then
		j = j + 1
		selfPlayer.Bag101[j] = selfPlayer.Bag101[j] or newTable()
		itemPointer = selfPlayer.Bag101[j]
		itemPointer.link = moneyTotal
		itemPointer.icon = GetCoinIcon(moneyTotal)
	end

	for i = #selfPlayer.Bag101, j+1, -1 do
		delTable(tremove(selfPlayer.Bag101))
	end

	selfPlayer.Bag101.size = min(max(4, j + j % 2), 18)	-- Size of mailbag is min 4, max 18, multiple of 2
	if bankPlayer == selfPlayer and BagContainerAr[101] and BagContainerAr[101]:IsVisible() then
		BagContainerAr[101]:Hide()
		BagButtonAr[101]:Click()
	end
end

function BankItems_SaveCurrency()
	local name, isHeader, isExpanded, isUnused, isWatched, count, icon
	local j = 0
	local itemPointer

	-- Save currency items as bag 102
	selfPlayer.Bag102 = selfPlayer.Bag102 or newTable()
	selfPlayer.Bag102.icon = ICON_Currency

	for i = 1, GetCurrencyListSize() do
		name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
		if name and name ~= "" and not isHeader and count > 0 then
			j = j + 1
			selfPlayer.Bag102[j] = selfPlayer.Bag102[j] or newTable()
			itemPointer = selfPlayer.Bag102[j]
			itemPointer.link = GetCurrencyListLink(i)
			itemPointer.count = count
			itemPointer.icon = icon
		end
	end

	for i = #selfPlayer.Bag102, j+1, -1 do
		delTable(tremove(selfPlayer.Bag102))
	end

	selfPlayer.Bag102.size = min(max(4, j + j % 2), 32) -- Limit to 32 for now
	if bankPlayer == selfPlayer and BagContainerAr[102] and BagContainerAr[102]:IsVisible() then
		BagContainerAr[102]:Hide()
		BagButtonAr[102]:Click()
	end
end

function BankItems_SaveVoidStorage()
	if not isVoidOpen then
		return
	end
	local itemID, textureName, locked, recentDeposit, isFiltered
	local itemPointer
	local j, slot, validCount = 0, 0, 0
	local i
	local k; --k-th void storage tab

	-- Save void storage items as bag 104
	selfPlayer.Bag104 = selfPlayer.Bag104 or newTable();
--	if selfPlayer.Bag104 then delTable(selfPlayer.Bag104) end
--	selfPlayer.Bag104 = newTable()

	selfPlayer.Bag104.icon = ICON_VoidStorage;

	--for each void storage tab
	for k = 1, VOID_STORAGE_PAGES do
		for i = 1, 80 do
			slot = slot + 1 --increment slots as we go
			slotAdjust[104][slot] = nil
			itemID, textureName, locked, recentDeposit, isFiltered = GetVoidItemInfo(k, i)
			if itemID and textureName and textureName ~= "" then
				j = slot --last occupied slot found
				validCount = validCount + 1 --total number of valid items found
				slotAdjust[104][validCount] = slot
				selfPlayer.Bag104[slot] = selfPlayer.Bag104[slot] or newTable()
				local _, link = GetItemInfo(itemID)
				itemPointer = selfPlayer.Bag104[slot]
				itemPointer.link = link
				itemPointer.icon = textureName
			else --need empty slot data available for new void storage container layout to be accurate
				selfPlayer.Bag104[slot] = delTable(selfPlayer.Bag104[slot])
			end
		end
	end
	-- j is last occupied slot
	--removed table deletion loop since empty slot tables are deleted in the main loop now

	selfPlayer.Bag104.size = min(max(4, validCount + validCount % 2), voidPageSize) -- Size of Void Bag is min 4, max voidPageSize, multiple of 2
	selfPlayer.Bag104.realSize = j
	--make sure you don't get stuck on an unused page with no paging buttons
	slot = max(ceil(j/selfPlayer.Bag104.size), 1)
	if voidPage > slot then
		voidPage = slot --swap pages if items are removed and new max page number is below current page
	end
	--update open bag/container
	if bankPlayer == selfPlayer then
		if BankItems_VoidFrame and BankItems_VoidFrame:IsVisible() then --new void storage frame is open
			BankItems_PopulateVoidStorage(BankItems_VoidFrame.currentTab) --force contents to update without hiding
		elseif BagContainerAr[104] and BagContainerAr[104]:IsVisible() then --old void storage bag is open
			BagContainerAr[104]:Hide()
			BagButtonAr[104]:Click()
		end
	end
end

function BankItems_SaveReagentBank()
--	if not isBankOpen then
--		return;
--	end;

	--6.0.2 Read the "Reagent Bank" tab
	--local REAGENTBANK_CONTAINER = -3;  defined in Constants.lua

	-- Save Reagent Bank window as bag 105
	selfPlayer.Bag105 = selfPlayer.Bag105 or newTable();
	selfPlayer.Bag105.icon = ICON_ReagentBank

	local j, validCount = 0, 0;
	local itemPointer;

	for slot = 1, NUM_REAGENTBANKGENERIC_SLOTS do
		local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(REAGENTBANK_CONTAINER, slot)
		slotAdjust[105][slot] = nil
		if link then
			j = slot --last occupied slot found
			validCount = validCount + 1 --total number of valid items found
			slotAdjust[105][validCount] = slot
			--print(link);
			selfPlayer.Bag105[slot] = selfPlayer.Bag105[slot] or newTable()
			itemPointer = selfPlayer.Bag105[slot]
			itemPointer.count = count and count > 1 and count or nil; -- fixed to proper item count in reagent bank
			itemPointer.link = link
			itemPointer.icon = texture
		else --need empty slot data available for new reagent bank container layout to be accurate
			selfPlayer.Bag105[slot] = delTable(selfPlayer.Bag105[slot])
		end;
	end;

	-- j is last occupied slot
	--removed table deletion loop since empty slot tables are deleted in the main loop now

	selfPlayer.Bag105.size = min(max(4, validCount + validCount % 2), reagentBankPageSize);
	selfPlayer.Bag105.realSize = j
	--make sure you don't get stuck on an unused page with no paging buttons
	local slot = max(ceil(j/selfPlayer.Bag105.size), 1)
	if reagentBankPage > slot then
		reagentBankPage = slot 
	end
	--update open bag/container
	if bankPlayer == selfPlayer then
		if BankItems_RBFrame and BankItems_RBFrame:IsVisible() then --new reagent bank frame is open
			BankItems_PopulateReagentBank() --force contents to update without hiding
		elseif BagContainerAr[105] and BagContainerAr[105]:IsVisible() then --old reagent bank bag is open
			BagContainerAr[105]:Hide()
			BagButtonAr[105]:Click()
		end
	end
end;

function BankItems_SaveAuctions()
	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo
	local itemPointer
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner")
	local j = 0

	-- Save Auctions as bag 103
	selfPlayer.Bag103 = selfPlayer.Bag103 or newTable()
	selfPlayer.Bag103.icon = ICON_AuctionHouse;
	selfPlayer.Bag103.time = time()

	for i = 1, totalAuctions do
		name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("owner", i)
		if name and saleStatus ~= 1 then
			j = j + 1
			selfPlayer.Bag103[j] = selfPlayer.Bag103[j] or newTable()
			itemPointer = selfPlayer.Bag103[j]
			itemPointer.link = GetAuctionItemLink("owner", i)
			itemPointer.count = count and count > 1 and count or nil
			itemPointer.AHexpiry = GetAuctionItemTimeLeft("owner", i)
		end
	end

	for i = #selfPlayer.Bag103, j+1, -1 do
		delTable(tremove(selfPlayer.Bag103))
	end

	selfPlayer.Bag103.size = min(max(4, j + j % 2), 18)	-- Size of AH Bag is min 4, max 18, multiple of 2
	if bankPlayer == selfPlayer and BagContainerAr[103] and BagContainerAr[103]:IsVisible() then
		BagContainerAr[103]:Hide()
		BagButtonAr[103]:Click()
	end
end

function BankItems_OpenBagsByBehavior(bank, inv, equip, mail, currency, auction, void, reagent)
	if inv then
		for i = 0, 4 do
			BagContainerAr[i]:Hide()
			BagButtonAr[i]:Click()
		end
	end
	if bank then
		for i = 5, 11 do
			BagContainerAr[i]:Hide()
			BagButtonAr[i]:Click()
		end
	end
	if equip then
		BagContainerAr[100]:Hide()
		BagButtonAr[100]:Click()
	end
	if mail then
		BagContainerAr[101]:Hide()
		BagButtonAr[101]:Click()
	end
	if currency then
		BagContainerAr[102]:Hide()
		BagButtonAr[102]:Click()
	end
	if auction then
		BagContainerAr[103]:Hide()
		BagButtonAr[103]:Click()
	end
	if void then
		if BankItems_Save.voidBags then --old void bag method
			BagContainerAr[104]:Hide()
			BagButtonAr[104]:Click()
		else --new Void Storage Frame
			if BankItems_VoidFrame:IsVisible() then
				BankItems_PopulateVoidStorage(BankItems_VoidFrame.currentTab)
			else
				ShowUIPanel(BankItems_VoidFrame)
			end
		end
	end
	if reagent then
		if BankItems_Save.reagentBags then --old reagent bag method
			BagContainerAr[105]:Hide()
			BagButtonAr[105]:Click()
		else --new Reagent Bank Frame
			if BankItems_RBFrame:IsVisible() then
				BankItems_PopulateReagentBank()
			else
				ShowUIPanel(BankItems_RBFrame)
			end
		end
	end
end

function BankItems_UpdateMoney()
	local total = 0
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			local _, realm = strsplit("|", key)
			if BankItems_Save.ShowAllRealms or (realm == selfPlayerRealm and (BankItems_Save.ShowOppositeFaction or value.faction == selfPlayer.faction)) then
				total = total + (value.money or 0)
			end
		end
	end
	MoneyFrame_Update("BankItems_MoneyFrameTotal", total)
	MoneyFrame_Update("BankItems_MoneyFrame", bankPlayer.money or 0)
end

function BankItems_PopulateFrame()
	-- Portrait
	if bankPlayer == selfPlayer then
		SetPortraitTexture(BankItems_Portrait, "player")
	else
		BankItems_Portrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
	end
	-- 28 bank slots (NUM_BANKGENERIC_SLOTS == 28)
	for i = 1, NUM_BANKGENERIC_SLOTS do
		if bankPlayer[i] then
			local quality
			if bankPlayer[i].link:find("battlepet") then
				local _, speciesID, _, breedQuality, _, _, _, _ = strsplit(":", bankPlayer[i].link)
				local _, peticon, _ = GetPetInfoBySpeciesID(speciesID);
				quality = tonumber(breedQuality)
				ItemButtonAr[i].icon:SetTexture(peticon)
			else
				quality = select(3, GetItemInfo(bankPlayer[i].link))
				ItemButtonAr[i].icon:SetTexture(GetItemIcon(bankPlayer[i].link))
			end
			if quality and (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
				ItemButtonAr[i].IconBorder:Show()
				ItemButtonAr[i].IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
			else
				ItemButtonAr[i].IconBorder:Hide()
			end
			if bankPlayer[i].count then
				ItemButtonAr[i].Count:Show()
				ItemButtonAr[i].Count:SetText(bankPlayer[i].count)
			else
				ItemButtonAr[i].Count:Hide()
			end
			if filterSearchText == "" or filterSearchText == SEARCH then
				ItemButtonAr[i].searchOverlay:Hide()
			else
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(bankPlayer[i].link)
				local temp = strmatch(bankPlayer[i].link, "%[(.*)%]")
				if strfind(strlower(temp), filterSearchText, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(strlower(_G[itemEquipLoc]), filterSearchText, 1, true)) then
					ItemButtonAr[i].searchOverlay:Hide()
				else
					ItemButtonAr[i].searchOverlay:Show()
				end
			end
		else
			ItemButtonAr[i].icon:SetTexture()
			ItemButtonAr[i].Count:Hide()
			ItemButtonAr[i].IconBorder:Hide()
			ItemButtonAr[i].searchOverlay:Hide()
		end
	end
	-- 12 bag slots
	for i = 0, 11 do
		if i == 0 then
			BagButtonAr[0].icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
			BagButtonAr[0].icon:SetVertexColor(1, 1, 1)
		elseif bankPlayer[format("Bag%d", i)] and bankPlayer[format("Bag%d", i)].link then
			BagButtonAr[i].icon:SetTexture(GetItemIcon(bankPlayer[format("Bag%d", i)].link))
			BagButtonAr[i].icon:SetVertexColor(1, 1, 1)
		else
			BagButtonAr[i].icon:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag")
			if i >= 5 then
				if bankPlayer["NumBankSlots"] and (i - 4) <= bankPlayer["NumBankSlots"] then
					BagButtonAr[i].icon:SetVertexColor(1, 1, 1)
				else
					BagButtonAr[i].icon:SetVertexColor(1, 0.1, 0.1)
				end
			else
				BagButtonAr[i].icon:SetVertexColor(1, 1, 1)
			end
		end
		BagButtonAr[i]:Show()
	end
	BankItems_FilterBags()
	
	-- Equipped items
	BagButtonAr[100].icon:SetTexture(ICON_Equipped_Items)
	BagButtonAr[100].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[100]:Show()
	-- Mail items
	BagButtonAr[101].icon:SetTexture(ICON_Mailbox)
	BagButtonAr[101].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[101]:Show()
	-- Currency Items
	BagButtonAr[102].icon:SetTexture(ICON_Currency)
	BagButtonAr[102].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[102]:Show()
	-- Void Storage
	BagButtonAr[104].icon:SetTexture(ICON_VoidStorage)
	BagButtonAr[104].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[104]:Show()
	-- AH Bag
	BagButtonAr[103].icon:SetTexture(ICON_AuctionHouse)
	BagButtonAr[103].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[103]:Show()
	-- Reagent Bag  icon by Mornadan
	BagButtonAr[105].icon:SetTexture(ICON_ReagentBank)
	BagButtonAr[105].icon:SetVertexColor(1, 1, 1)
	BagButtonAr[105]:Show()
	-- Money
	BankItems_UpdateMoney()
	-- Location
	if bankPlayer.location then
		BankItems_TitleText:SetText(gsub(bankPlayerName, "|", L[" of "]).." ("..bankPlayer.location..")")
	else
		BankItems_TitleText:SetText(gsub(bankPlayerName, "|", L[" of "]))
	end
end

function BankItems_PopulateBag(bagID)
	local _, button, theBag, idx, textureName
	theBag = bankPlayer[format("Bag%d", bagID)]
	if theBag and theBag.size then
		for bagItem = 1, theBag.size do
			button = BagContainerAr[bagID][bagItem]
			idx = theBag.size - (bagItem - 1)
			if (bagID == 101) then  -- Adjust for page number
				idx = idx + (mailPage - 1) * 18
				BagContainerAr[101].mailtext:SetText(((mailPage - 1) * 18 + 1).."-"..min(mailPage * 18, #bankPlayer.Bag101).."/"..#bankPlayer.Bag101)
				if theBag.size >= 18 then
					BagContainerAr[101].mailtext:Show()
					BankItems_NextMailButton:Show()
					BankItems_PrevMailButton:Show()
				else
					BagContainerAr[101].mailtext:Hide()
					BankItems_NextMailButton:Hide()
					BankItems_PrevMailButton:Hide()
				end
			elseif (bagID == 103) then  -- Adjust for page number
				idx = idx + (AHPage - 1) * 18
				BagContainerAr[103].mailtext:SetText(((AHPage - 1) * 18 + 1).."-"..min(AHPage * 18, #bankPlayer.Bag103).."/"..#bankPlayer.Bag103)
				if theBag.size >= 18 then
					BagContainerAr[103].mailtext:Show()
					BankItems_NextAHButton:Show()
					BankItems_PrevAHButton:Show()
				else
					BagContainerAr[103].mailtext:Hide()
					BankItems_NextAHButton:Hide()
					BankItems_PrevAHButton:Hide()
				end
			elseif bagID == 104 then -- Adjust for page number
				idx = idx + (voidPage - 1) * voidPageSize
				idx = slotAdjust[104][idx]
				BagContainerAr[104].mailtext:SetText(((voidPage - 1) * voidPageSize + 1).."-"..min(voidPage * voidPageSize, #slotAdjust[104]).."/"..#slotAdjust[104])
				if #slotAdjust[104] >= voidPageSize then
					BagContainerAr[104].mailtext:Show()
					BankItems_NextVoidButton:Show()
					BankItems_PrevVoidButton:Show()
				else
					BagContainerAr[104].mailtext:Hide()
					BankItems_NextVoidButton:Hide()
					BankItems_PrevVoidButton:Hide()
				end
			elseif bagID == 105 then -- Adjust for page number
				idx = idx + (reagentBankPage - 1) * reagentBankPageSize
				idx = slotAdjust[105][idx]
				BagContainerAr[105].mailtext:SetText(((reagentBankPage - 1) * reagentBankPageSize + 1).."-"..min(reagentBankPage * reagentBankPageSize, #slotAdjust[105]).."/"..#slotAdjust[105])
				if #slotAdjust[105] >= reagentBankPageSize then
					BagContainerAr[105].mailtext:Show()
					BankItems_NextReagentButton:Show()
					BankItems_PrevReagentButton:Show()
				else
					BagContainerAr[105].mailtext:Hide()
					BankItems_NextReagentButton:Hide()
					BankItems_PrevReagentButton:Hide()
				end
			end
			if theBag[idx] then
				local link = theBag[idx].link
				if bagID == 102 then
					button.icon:SetTexture(theBag[idx].icon)
				elseif type(link) == "number" then
					--button.icon:SetTexture(theBag[idx].icon)
					button.icon:SetTexture(GetCoinIcon(link))
				else
					local quality
					if link:find("battlepet") then
						local _, speciesID, _, breedQuality, _, _, _, _ = strsplit(":", link)
						local _, peticon, _ = GetPetInfoBySpeciesID(speciesID);
						quality = tonumber(breedQuality)
						button.icon:SetTexture(peticon)
					elseif link:find("Hkeystone") then
						quality = select(3, GetItemInfo(KeystoneItemID))
						button.icon:SetTexture(GetItemIcon(KeystoneItemID))
					else
						quality = select(3, GetItemInfo(link))
						button.icon:SetTexture(GetItemIcon(link))
					end
					if quality and (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
						button.IconBorder:Show()
						button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
					else
						button.IconBorder:Hide()
					end
				end
				if theBag[idx].count then
					button.Count:Show()
					button.Count:SetText(theBag[idx].count)
				else
					button.Count:Hide()
				end
				if filterSearchText == "" or filterSearchText == SEARCH then
					button.searchOverlay:Hide()
				elseif type(link) == "string" then
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(link)
					local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(link, "%[(.*)%]")))
					local filterlocalized=BankItems_SpecialCharactersLocalization(strlower(filterSearchText))
					if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
						button.searchOverlay:Hide()
					else
						button.searchOverlay:Show()
					end
				else
					button.searchOverlay:Show()
				end
			else
				if bagID == 100 then
					if idx == 18 then
						-- Tabard fix
						idx = 19
					end
					_, textureName = GetInventorySlotInfo(BANKITEMS_INVSLOT[idx])
					button.icon:SetTexture(textureName)
				else
					button.icon:SetTexture()
				end
				button.Count:Hide()
				button.IconBorder:Hide()
				button.searchOverlay:Hide()
			end
		end
	end
end

-- Prehook SetItemSearch
local Orig_SetItemSearch = SetItemSearch
function SetItemSearch(text, ...)
	filterSearchText = strlower(text)
	return Orig_SetItemSearch(text, ...)
end

--Remove accents to make filter not accent sensitive like Blizzard UI search and filters
local accentedChars = {"à","á","â","ã","ä","å","æ","ç","è","é","ê","ë","ì","í","î","ï","ñ","ò","ó","ô","õ","ö","ø","ù","ú","û","ü","ý","ÿ","œ","š","ž","ƒ"}
local standardChars = {"a","a","a","a","a","a","ae","c","e","e","e","e","i","i","i","i","n","o","o","o","o","o","o","u","u","u","u","y","y","oe","s","z","f"}
function BankItems_SpecialCharactersLocalization(text)
	for char = 1, #accentedChars do
		if strfind(text, accentedChars[char]) then
			text = gsub(text, accentedChars[char], standardChars[char])
		end
	end
	return text
end

function BankItems_FilterBags()
	if not BankItems_Frame:IsVisible() and not BankItems_RBFrame:IsVisible() and not BankItems_VoidFrame:IsVisible() and not BankItems_GBFrame:IsVisible() then return end

	if filterSearchText == "" or filterSearchText == SEARCH then
		for num = 1, NUM_BANKGENERIC_SLOTS do
			ItemButtonAr[num].searchOverlay:Hide()
		end
		for num = 1, NUM_REAGENTBANKGENERIC_SLOTS do --reagent bank
			RBButtonAr[num].searchOverlay:Hide()
		end
		for num = 1, VOID_STORAGE_MAX do --void storage
			VoidButtonAr[num].searchOverlay:Hide()
		end
		for num = 1, 98 do --guild bank
			GBButtonAr[num].searchOverlay:Hide()
		end
		for _, bagID in ipairs(BAGNUMBERS) do
			local theBag = bankPlayer[format("Bag%d", bagID)]
			if theBag and (bagID ~= 105 or BankItems_Save.reagentBags) and (bagID ~= 104 or BankItems_Save.voidBags) then --skip Reagent and Void Storage bags unless option to show as a bag is set
				for bagItem = 1, theBag.size do
					BagContainerAr[bagID][bagItem].searchOverlay:Hide()
				end
			end
			BagButtonAr[bagID].searchOverlay:Hide()
			BagButtonAr[bagID].showOverlay = false
		end
		for num = 1, VOID_STORAGE_PAGES do
			VoidTabFrameAr[num].showOverlay = false
			VoidTabFrameAr[num].searchOverlay:Hide()
		end
		for num = 1, 8 do
			GBTabFrameAr[num].showOverlay = false
			GBTabFrameAr[num].searchOverlay:Hide()
		end
	else
		local filterlocalized=BankItems_SpecialCharactersLocalization(strlower(filterSearchText))
		for num = 1, NUM_BANKGENERIC_SLOTS do
			if bankPlayer[num] then
				local itemName, _, _, _, _, _, _, _, itemEquipLoc  = GetItemInfo(bankPlayer[num].link)
				local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(bankPlayer[num].link, "%[(.*)%]")))
				if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
					ItemButtonAr[num].searchOverlay:Hide()
				else
					ItemButtonAr[num].searchOverlay:Show()
				end
			end
		end
		if not BankItems_Save.reagentBags then
			BagButtonAr[105].showOverlay = true
			BagButtonAr[105].searchOverlay:Hide()
			for num = 1, NUM_REAGENTBANKGENERIC_SLOTS do --Reagent Bank Frame
				if bankPlayer.Bag105[num] then
					local itemName, _, _, _, _, _, _, _, itemEquipLoc  = GetItemInfo(bankPlayer.Bag105[num].link)
					local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(bankPlayer.Bag105[num].link, "%[(.*)%]")))
					if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
						RBButtonAr[num].searchOverlay:Hide()
						BagButtonAr[105].searchOverlay:Hide()
						BagButtonAr[105].showOverlay = false
					else
						RBButtonAr[num].searchOverlay:Show()
					end
				else
					RBButtonAr[num].searchOverlay:Hide()
				end
			end
			if BagButtonAr[105].showOverlay then
				BagButtonAr[105].searchOverlay:Show()
			end
		end
		if not BankItems_Save.voidBags then
			if bankPlayer.Bag104 then
				local current = BankItems_VoidFrame.currentTab or 1
				BagButtonAr[104].showOverlay = true
				BagButtonAr[104].searchOverlay:Hide()
				for tab = 1, VOID_STORAGE_PAGES do
					VoidTabFrameAr[tab].showOverlay = true
					VoidTabFrameAr[tab].searchOverlay:Hide()
					for num = ((tab-1)*VOID_STORAGE_MAX + 1) , ((tab-1)*VOID_STORAGE_MAX + VOID_STORAGE_MAX) do
						if bankPlayer.Bag104[num] then
							local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(bankPlayer.Bag104[num].link)
							local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(bankPlayer.Bag104[num].link, "%[(.*)%]")))
							if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
								if  tab == current then
									VoidButtonAr[num - ((tab-1) * VOID_STORAGE_MAX)].searchOverlay:Hide()
								end
								BagButtonAr[104].searchOverlay:Hide()
								BagButtonAr[104].showOverlay = false
								VoidTabFrameAr[tab].showOverlay = false
							elseif tab == current then
								VoidButtonAr[num - ((tab-1) * VOID_STORAGE_MAX)].searchOverlay:Show()
							end
						elseif tab == current then
							VoidButtonAr[num - ((tab-1) * VOID_STORAGE_MAX)].searchOverlay:Hide()
						end
					end
					if VoidTabFrameAr[tab].showOverlay then
						VoidTabFrameAr[tab].searchOverlay:Show()
					end
				end
				if BagButtonAr[104].showOverlay then
					BagButtonAr[104].searchOverlay:Show()
				end
			else
				for num = 1, VOID_STORAGE_PAGES do
					VoidTabFrameAr[num].showOverlay = true
					VoidTabFrameAr[num].searchOverlay:Show()
				end
				BagButtonAr[104].searchOverlay:Show()
			end
		end
		if BankItems_GBFrame:IsVisible() then
			if BankItems_GuildDropdown.selectedValue then
				local selfGuild = BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue]
				local current = BankItems_GBFrame.currentTab or 1
				for tab = 1, 8 do
					GBTabFrameAr[tab].showOverlay = true
					GBTabFrameAr[tab].searchOverlay:Hide()
					if selfGuild[tab] and selfGuild[tab].seen then
						for num = 1 , 98 do
							if selfGuild[tab][num] then
								local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(selfGuild[tab][num].link)
								local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(selfGuild[tab][num].link, "%[(.*)%]")))
								if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
									if tab == current then
										GBButtonAr[num].searchOverlay:Hide()
									end
									GBTabFrameAr[tab].showOverlay = false
								elseif tab == current then
									GBButtonAr[num].searchOverlay:Show()
								end
							elseif tab == current then
								GBButtonAr[num].searchOverlay:Hide()
							end
						end
					end
					if GBTabFrameAr[tab].showOverlay then
						GBTabFrameAr[tab].searchOverlay:Show()
					end
				end
			else
				for num = 1, 8 do
					GBTabFrameAr[num].showOverlay = true
					GBTabFrameAr[num].searchOverlay:Show()
				end
			end
		end
		for _, bagID in ipairs(BAGNUMBERS) do
			local theBag = bankPlayer[format("Bag%d", bagID)]
			if theBag and (bagID ~= 105 or BankItems_Save.reagentBags) and (bagID ~= 104 or BankItems_Save.voidBags) then --skip Reagent and Void Storage bags unless option to show as a bag is set
				BagButtonAr[bagID].showOverlay = true
				for bagItem = 1, theBag.size do
					local button = BagContainerAr[bagID][bagItem]
					local idx = theBag.size - (bagItem - 1)
					if (bagID == 101) then  -- Adjust for page number
						idx = idx + (mailPage - 1) * 18
					elseif (bagID == 103) then  -- Adjust for page number
						idx = idx + (AHPage - 1) * 18
					elseif bagID == 104 then -- Adjust for page number
						idx = idx + (voidPage - 1) * voidPageSize
						idx = slotAdjust[104][idx]
					elseif (bagID == 105) then  -- Adjust for page number
						idx = idx + (reagentBankPage - 1) * reagentBankPageSize
						idx = slotAdjust[105][idx]
					end
					if theBag[idx] then
						if type(theBag[idx].link) == "string" then
							local itemName, _, _, _, _, _, _, _, itemEquipLoc  = GetItemInfo(theBag[idx].link)
							local temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag[idx].link, "%[(.*)%]")))
							if strfind(temp, filterlocalized, 1, true) or (itemEquipLoc and _G[itemEquipLoc] and strfind(BankItems_SpecialCharactersLocalization(strlower(_G[itemEquipLoc])), filterlocalized, 1, true)) then
								button.searchOverlay:Hide()
								BagButtonAr[bagID].searchOverlay:Hide()
								BagButtonAr[bagID].showOverlay = false
							else
								button.searchOverlay:Show()
							end
						else
							button.searchOverlay:Show()
						end
					else
						button.searchOverlay:Hide()
					end
				end
				if BagButtonAr[bagID].showOverlay then
					BagButtonAr[bagID].searchOverlay:Show()
				end
			elseif (bagID ~= 105 or BankItems_Save.reagentBags) and (bagID ~= 104 or BankItems_Save.voidBags) then
				BagButtonAr[bagID].searchOverlay:Show()
			end
		end
	end
end

function BankItemsUpdateCFrameAnchors()
	local BANKITEMS_BOTTOM_SCREEN_LIMIT2 = BANKITEMS_BOTTOM_SCREEN_LIMIT / BankItems_Frame:GetScale()  -- scale it
	local prevBag, currBag, colBag
	local freeScreenHeight = BankItems_Frame:GetBottom() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
	local col

	-- First bag
	if BankItemsCFrames.bags[1] then
		prevBag = getglobal(BankItemsCFrames.bags[1])
		colBag = prevBag
		if freeScreenHeight < prevBag:GetHeight() then
			-- No space in column 1, so anchor in column 3
			prevBag:SetPoint("TOPLEFT", BankItems_Frame, "TOPRIGHT", 0, 0)
			freeScreenHeight = BankItems_Frame:GetTop() - prevBag:GetHeight() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
			col = 3
		else
			-- Anchor in column 1
			prevBag:SetPoint("TOPLEFT", BankItems_Frame, "BOTTOMLEFT", 8, 0)
			freeScreenHeight = freeScreenHeight - prevBag:GetHeight()
			col = 1
		end
	end

	local index = 2
	while BankItemsCFrames.bags[index] do
		-- Anchor current bag to the previous bag
		currBag = getglobal(BankItemsCFrames.bags[index])

		if freeScreenHeight < currBag:GetHeight() then
			-- No space, so anchor in next column
			if col == 1 then
				-- Check column 2
				freeScreenHeight = BankItems_Frame:GetBottom() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
				if freeScreenHeight < currBag:GetHeight() then
					-- No space in column 2, so anchor in column 3
					currBag:SetPoint("TOPLEFT", BankItems_Frame, "TOPRIGHT", 0, 0)
					freeScreenHeight = BankItems_Frame:GetTop() - currBag:GetHeight() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
				else
					-- Anchor in column 2
					currBag:SetPoint("TOPLEFT", colBag, "TOPRIGHT", 0, 0)
					freeScreenHeight = BankItems_Frame:GetBottom() - currBag:GetHeight() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
				end
			elseif col == 2 then
				-- Anchor in column 3
				currBag:SetPoint("TOPLEFT", BankItems_Frame, "TOPRIGHT", 0, 0)
				freeScreenHeight = BankItems_Frame:GetTop() - currBag:GetHeight() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
			else
				-- Anchor in next column relative to colBag
				currBag:SetPoint("TOPLEFT", colBag, "TOPRIGHT", 0, 0)
				freeScreenHeight = BankItems_Frame:GetTop() - currBag:GetHeight() - BANKITEMS_BOTTOM_SCREEN_LIMIT2
			end
			colBag = currBag
			col = col + 1
		else
			-- Anchor below prevBag
			currBag:SetPoint("TOPLEFT", prevBag, "BOTTOMLEFT", 0, 0)
			freeScreenHeight = freeScreenHeight - currBag:GetHeight()
		end

		prevBag = currBag
		index = index + 1
	end
end

function BankItems_updateContainerFrameAnchors()
	-- There's a note on this function at the top of this file and the taint that it causes
	-- when using it to replace Blizzard's version.
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
	local screenWidth = GetScreenWidth()
	local containerScale = 1
	local leftLimit = 0
	if BankFrame:IsVisible() then
		leftLimit = BankFrame:GetRight() - 25
	end
	if BankItems_Frame:IsVisible() then
		if leftLimit < BankItems_Frame:GetRight() * BankItems_Frame:GetScale() then
			leftLimit = BankItems_Frame:GetRight() * BankItems_Frame:GetScale()
		end
	end

	while containerScale > CONTAINER_SCALE do
		screenHeight = GetScreenHeight() / containerScale
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale
		yOffset = CONTAINER_OFFSET_Y / containerScale
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset
		leftMostPoint = screenWidth - xOffset
		column = 1
		local frameHeight
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = getglobal(frameName):GetHeight()
			if freeScreenHeight < frameHeight then
				-- Start a new column
				column = column + 1
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset
				freeScreenHeight = screenHeight - yOffset
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
		end
		if leftMostPoint < leftLimit then
			containerScale = containerScale - 0.01
		else
			break
		end
	end

	if containerScale < CONTAINER_SCALE then
		containerScale = CONTAINER_SCALE
	end

	screenHeight = GetScreenHeight() / containerScale
	-- Adjust the start anchor for bags depending on the multibars
	xOffset = CONTAINER_OFFSET_X / containerScale
	yOffset = CONTAINER_OFFSET_Y / containerScale
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset
	column = 0
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = getglobal(frameName)
		frame:SetScale(containerScale)
		if index == 1 then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset )
		elseif freeScreenHeight < frame:GetHeight() then
			-- Start a new column
			column = column + 1
			freeScreenHeight = screenHeight - yOffset
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset )
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING
	end
end

function BankItems_UserDropdown_Sort(a, b)
	-- Sorting code courtesy of doxxx
	local nameA, realmA = strsplit("|", a)
	local nameB, realmB = strsplit("|", b)
	if nameA == nameB then
		return realmA < realmB
	else
		return nameA < nameB
	end
end

function BankItems_UserDropdownGenerateKeys()
	for k, v in pairs(sortedKeys) do
		sortedKeys[k] = nil
	end
	for key, value in pairs(BankItems_Save) do
		if type(value) == "table" and key ~= "Behavior" and key ~= "Behavior2" then
			local _, realm = strsplit("|", key)
			if BankItems_Save.ShowAllRealms or (realm == selfPlayerRealm and (BankItems_Save.ShowOppositeFaction or value.faction == selfPlayer.faction)) then
				tinsert(sortedKeys, key)
			end
		end
	end
	table.sort(sortedKeys, BankItems_UserDropdown_Sort)
end

function BankItems_UserDropdown_OnClick(button, playerName, text)
	text = text or gsub(playerName, "|", L[" of "])
	CloseDropDownMenus()
	BankItems_UserDropdownText:SetText(text)
	BankItems_UserDropdown.selectedValue = playerName
	BankItems_SetPlayer(playerName)

	BankItems_Frame_OnHide()
	local validCount = 0
	for i = 1, (VOID_STORAGE_PAGES*VOID_STORAGE_MAX) do
		slotAdjust[104][i] = nil
		if bankPlayer.Bag104 and bankPlayer.Bag104[i] then
			validCount = validCount + 1
			slotAdjust[104][validCount] = i
		end
	end
	validCount = 0
	for i = 1, NUM_REAGENTBANKGENERIC_SLOTS do
		slotAdjust[105][i] = nil
		if bankPlayer.Bag105 and bankPlayer.Bag105[i] then
			validCount = validCount + 1
			slotAdjust[105][validCount] = i
		end
	end
	BankItems_PopulateFrame()
	if not BankItems_Save.voidBags and BankItems_VoidFrame and BankItems_VoidFrame:IsVisible() then --update Void Storage Frame on character change if not displayed as a bag
		BankItems_PopulateVoidStorage(BankItems_VoidFrame.currentTab)
	end
	if not BankItems_Save.reagentBags and BankItems_RBFrame and BankItems_RBFrame:IsVisible() then --update Reagent Bank Frame on character change if not displayed as a bag
		BankItems_PopulateReagentBank()
	end
	BankItems_OpenBagsByBehavior(unpack(BankItems_Save.Behavior))
end

function BankItems_UserDropdown_Initialize()
	for _, key in ipairs(sortedKeys) do
		local f = BankItems_Save[key].faction
		if f == "Alliance" then f = FACTION_ALLIANCE
		elseif f == "Horde" then f = FACTION_HORDE
		else f = UNKNOWN
		end
		info.text = gsub(key, "|", L[" of "]).." ("..f..")"
		info.arg1 = key
		info.arg2 = gsub(key, "|", L[" of "])
		info.func = BankItems_UserDropdown_OnClick
		info.checked = (bankPlayerName == info.arg1)
		info.keepShownOnClick = nil
		info.isNotRadio = 1
		UIDropDownMenu_AddButton(info)
	end
end

function BankItems_GenerateExportText()
	local t = newTable()
	local line = 1
	t[1] = L["Contents of:"].." "..gsub(bankPlayerName, "|", L[" of "]).."\n"
	local prefix = ""
	local errorflag = false
	BankItems_ExportFrame.mode = "export"
	BankItems_ExportFrame_ResetButton:SetText(RESET)
	BankItems_ExportFrame_SearchTextbox:Hide()
	BankItems_ExportFrame_SearchAllRealms:Hide()
	BankItems_ExportFrame_ShowBagPrefix:SetChecked(BankItems_Save.ExportPrefix)
	BankItems_ExportFrame_GroupData:SetChecked(BankItems_Save.GroupExportData)
	BankItems_ExportFrame_SearchDropDown:Hide()
	BankItems_ExportFrame_Scroll:SetHeight(310)
	BankItems_ExportFrame_ScrollText:SetHeight(304)

	if BankItems_Save.GroupExportData then
		-- Group similar items together in the report
		local data = newTable()
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture
		for num = 1, NUM_BANKGENERIC_SLOTS do
			if bankPlayer[num] then
				itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(bankPlayer[num].link)
				if itemType then
					data[itemType] = data[itemType] or newTable()
					data[itemType][itemName] = (data[itemType][itemName] or 0) + (bankPlayer[num].count or 1)
				else
					errorflag = true
				end
			end
		end
		for _, bagNum in ipairs(BAGNUMBERS) do
			local theBag = bankPlayer[format("Bag%d", bagNum)]
			if bagNum ~= 103 and theBag then
			--if theBag then
				local realSize = theBag.size
				if bagNum == 101 then
					realSize = #theBag
				elseif bagNum == 104 or bagNum == 105 then
					realSize = theBag.realSize or #theBag --users of new version that haven't had void or reagent banks update on a character use #theBag since it will still work and others use the realSize saved variable
				end
				for bagItem = 1, realSize do
					if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
						itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(theBag[bagItem].link)
						if itemType then
							data[itemType] = data[itemType] or newTable()
							data[itemType][itemName] = (data[itemType][itemName] or 0) + (theBag[bagItem].count or 1)
						elseif strmatch(theBag[bagItem].link, "(currency:%d+)") then
							itemName = BankItems_ParseLink(theBag[bagItem].link)
							data[CURRENCY] = data[CURRENCY] or newTable()
							data[CURRENCY][itemName] = (data[CURRENCY][itemName] or 0) + (theBag[bagItem].count or 1)
						else
							errorflag = true
						end
					end
				end
				if type(theBag.link) == "string" then
					itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(theBag.link)
					if itemType then
						data[itemType] = data[itemType] or newTable()
						data[itemType][itemName] = (data[itemType][itemName] or 0) + 1
					elseif strmatch(theBag.link, "(currency:%d+)") then
						itemName = BankItems_ParseLink(theBag.link)
						data[CURRENCY] = data[CURRENCY] or newTable()
						data[CURRENCY][itemName] = (data[CURRENCY][itemName] or 0) + 1
					else
						errorflag = true
					end
				end
			end
		end

		-- Generate the report
		for itemType, items in pairs(data) do
			line = line + 1
			t[line] = itemType
			for itemName, count in pairs(items) do
				line = line + 1
				t[line] = format("%d %s", count, itemName)
			end
			line = line + 1
			t[line] = ""
		end
		if errorflag then
			line = line + 1
			t[line] = L["BANKITEMS_CAUTION_TEXT"]
		end
		delTable(data)
	else
		-- Don't group similar items together in the report
		for num = 1, NUM_BANKGENERIC_SLOTS do
			if bankPlayer[num] then
				if BankItems_Save.ExportPrefix then
					prefix = format(L["Bank Item %d:"], num).." "
				end
				line = line + 1
				t[line] = format("%s%d %s", prefix, bankPlayer[num].count or 1, BankItems_ParseLink(bankPlayer[num].link))
			end
		end
		for _, bagNum in ipairs(BAGNUMBERS) do
			local theBag = bankPlayer[format("Bag%d", bagNum)]
			if bagNum ~= 103 and theBag then
			--if theBag then
				local realSize = theBag.size
				if bagNum == 101 then
					realSize = #theBag
				elseif bagNum == 104 or bagNum == 105 then
					realSize = theBag.realSize or #theBag
				end
				for bagItem = 1, realSize do
					if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
						if BankItems_Save.ExportPrefix then
							if bagNum == 100 then
								prefix = L["Equipped"]..": "
							elseif bagNum == 101 then
								prefix = MINIMAP_TRACKING_MAILBOX..": "
							elseif bagNum == 102 then
								prefix = CURRENCY..": "
							elseif bagNum == 104 then
								prefix = VOID_STORAGE..": "
							elseif bagNum == 105 then
								prefix = REAGENT_BANK..": "
							else
								prefix = format(L["Bag %d Item %d:"], bagNum, bagItem).." "
							end
						end
						line = line + 1
						t[line] = format("%s%d %s", prefix, theBag[bagItem].count or 1, BankItems_ParseLink(theBag[bagItem].link))
					end
				end
				if type(theBag.link) == "string" then
					if BankItems_Save.ExportPrefix then
						prefix = L["Equipped"]..": "
					end
					line = line + 1
					t[line] = format("%s%d %s", prefix, 1, BankItems_ParseLink(theBag.link))
				end
			end
		end
	end

	if bankPlayer.money then
		line = line + 1
		t[line] = "\n"..L["Money:"].." "..BankItem_ParseMoney(bankPlayer.money).."\n"
	end

	BankItems_ExportFrame_ScrollText:SetText(table.concat(t, "\n"))
	delTable(t)
end

function BankItems_Search(searchText)
	local t = newTable()
	local line = 0
	local prefix = "     "
	local temp
	local count
	local searchTextOrg=searchText
	searchText = BankItems_SpecialCharactersLocalization(strlower(searchText))

	-- Search filter setup
	local searchFilter = newTable()
	for i = 0, 4 do
		searchFilter[i] = BankItems_Save.Behavior2[2]
	end
	for i = 5, 11 do
		searchFilter[i] = BankItems_Save.Behavior2[1]
	end
	searchFilter[100] = BankItems_Save.Behavior2[3]
	searchFilter[101] = BankItems_Save.Behavior2[4]
	searchFilter[102] = BankItems_Save.Behavior2[2]
	searchFilter[104] = BankItems_Save.Behavior2[1] -- consider void storage a bank bag for filtering purposes
	searchFilter[105] = BankItems_Save.Behavior2[1] -- consider Reagent Bank a bank bag for filtering purposes

	if BankItems_Save.GroupExportData then
		-- Group similar items together in the report
		local data = newTable()
		for key, bankPlayer in pairs(BankItems_Save) do
			local _, realm = strsplit("|", key)
			if type(bankPlayer) == "table" and (BankItems_Save.SearchAllRealms or (realm == selfPlayerRealm and bankPlayer.faction == selfPlayer.faction)) and key ~= "Behavior" and key ~= "Behavior2" then
				if BankItems_Save.Behavior2[1] then
					for num = 1, NUM_BANKGENERIC_SLOTS do
						if bankPlayer[num] then
							temp = strmatch(bankPlayer[num].link, "%[(.*)%]")
							templocalized = BankItems_SpecialCharactersLocalization(strlower(strmatch(bankPlayer[num].link, "%[(.*)%]")))
							if strfind(templocalized, searchText, 1, true) then
								data[temp] = data[temp] or newTable()
								data[temp][key] = data[temp][key] or newTable()
								data[temp][key].count = (data[temp][key].count or 0) + (bankPlayer[num].count or 1)
								data[temp][key].bank = (data[temp][key].bank or 0) + (bankPlayer[num].count or 1)
							end
						end
					end
				end
				for _, bagNum in ipairs(BAGNUMBERS) do
					local theBag = bankPlayer[format("Bag%d", bagNum)]
					if searchFilter[bagNum] and theBag then
						local realSize = theBag.size
						if bagNum == 101 then
							realSize = #theBag
						elseif bagNum == 104 or bagNum == 105 then
							realSize = theBag.realSize or #theBag
						end
						for bagItem = 1, realSize do
							if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
								temp = strmatch(theBag[bagItem].link, "%[(.*)%]")
								templocalized = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag[bagItem].link, "%[(.*)%]")))
								if strfind(templocalized, searchText, 1, true) then
									data[temp] = data[temp] or newTable()
									data[temp][key] = data[temp][key] or newTable()
									data[temp][key].count = (data[temp][key].count or 0) + (theBag[bagItem].count or 1)
									if bagNum >= 0 and bagNum <= 4 then
										data[temp][key].inv = (data[temp][key].inv or 0) + (theBag[bagItem].count or 1)
									elseif bagNum == 100 then
										data[temp][key].equipped = (data[temp][key].equipped or 0) + (theBag[bagItem].count or 1)
									elseif bagNum == 102 then
										data[temp][key].currency = (data[temp][key].currency or 0) + (theBag[bagItem].count or 1)
									elseif bagNum == 101 then
										data[temp][key].mail = (data[temp][key].mail or 0) + (theBag[bagItem].count or 1)
									elseif bagNum == 104 then
										data[temp][key].voidstorage = (data[temp][key].voidstorage or 0) + (theBag[bagItem].count or 1)
									elseif bagNum == 105 then
										data[temp][key].reagentbank = (data[temp][key].reagentbank or 0) + (theBag[bagItem].count or 1)
									else
										data[temp][key].bank = (data[temp][key].bank or 0) + (theBag[bagItem].count or 1)
									end
								end
							end
						end
						if type(theBag.link) == "string" then
							temp = strmatch(theBag.link, "%[(.*)%]")
							templocalized = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag.link, "%[(.*)%]")))
							if strfind(templocalized, searchText, 1, true) then
								data[temp] = data[temp] or newTable()
								data[temp][key] = data[temp][key] or newTable()
								data[temp][key].count = (data[temp][key].count or 0) + (theBag.count or 1)
								data[temp][key].equipped = (data[temp][key].equipped or 0) + (theBag.count or 1)
							end
						end
					end
				end
			end
		end

		if BankItems_Save.Behavior2[5] then	-- Search guild banks too
			for key, bankPlayer in pairs(BankItems_SaveGuild) do
				local _, realm = strsplit("|", key)
				if type(bankPlayer) == "table" and (BankItems_Save.SearchAllRealms or (realm == selfPlayerRealm and bankPlayer.faction == selfPlayer.faction)) then
					for tab = 1, MAX_GUILDBANK_TABS do
						if bankPlayer[tab] and bankPlayer[tab].seen then
							-- Tab exists and seen before
							local theBag = bankPlayer[tab]
							for bagItem = 1, 98 do
								if theBag[bagItem] then
									temp = strmatch(theBag[bagItem].link, "%[(.*)%]")
									templocalized = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag[bagItem].link, "%[(.*)%]")))
									if strfind(templocalized, searchText, 1, true) then
										data[temp] = data[temp] or newTable()
										data[temp][key] = data[temp][key] or newTable()
										data[temp][key].count = (data[temp][key].count or 0) + (theBag[bagItem].count or 1)
										data[temp][key].gbank = (data[temp][key].gbank or 0) + (theBag[bagItem].count or 1)
									end
								end
							end
						end
					end
				end
			end
		end

		local baginfos = {
			{ L["Bank"] },
			{ L["Bags"] },
			{ L["Equipped"] },
			{ MAIL_LABEL },
			{ GUILD_BANK },
			{ CURRENCY },
			{ VOID_STORAGE },
			{ REAGENT_BANK }
		}
		-- Generate the report
		for itemName, whotable in pairs(data) do
			line = line + 1
			local line2 = line
			local totalCount = 0
			for who, counttable in pairs(whotable) do
				local name
				if counttable.gbank then
					name = gsub(who, "(.*)|", "<%1>"..L[" of "])
				else
					name = gsub(who, "|", L[" of "])
				end
				totalCount = totalCount + counttable.count

				baginfos[1][2] = counttable.bank
				baginfos[2][2] = counttable.inv
				baginfos[3][2] = counttable.equipped
				baginfos[4][2] = counttable.mail
				baginfos[5][2] = counttable.gbank
				baginfos[6][2] = counttable.currency
				baginfos[7][2] = counttable.voidstorage
				baginfos[8][2] = counttable.reagentbank
				local text = format("     %d %s (", counttable.count, name);
				local first = true
				for i = 1, #baginfos do
					if baginfos[i][2] then
						if not first then text = text..", " end
						text = text..baginfos[i][1].." "..baginfos[i][2]
						first = false
					end
				end
				text = text..")"
				line2 = line2 + 1
				t[line2] = text
			end
			t[line] = format("%s (%d)", itemName, totalCount)
			line2 = line2 + 1
			t[line2] = ""
			line = line2
		end
		delTable(data)
	else
		-- Don't group similar items together in the report
		for key, bankPlayer in pairs(BankItems_Save) do
			local _, realm = strsplit("|", key)
			if type(bankPlayer) == "table" and (BankItems_Save.SearchAllRealms or (realm == selfPlayerRealm and bankPlayer.faction == selfPlayer.faction)) and key ~= "Behavior" and key ~= "Behavior2" then
				count = 0
				if BankItems_Save.Behavior2[1] then
					for num = 1, NUM_BANKGENERIC_SLOTS do
						if bankPlayer[num] then
							if BankItems_Save.ExportPrefix then
								prefix = "     "..L["Bank Item %d:"]:format(num).." "
							end
							temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(bankPlayer[num].link, "%[(.*)%]")))
							if strfind(temp, searchText, 1, true) then
								count = count + 1
								if count == 1 then
									line = line + 1
									t[line] = L["Contents of:"].." "..gsub(key, "|", L[" of "])
								end
								line = line + 1
								t[line] = format("%s%d %s", prefix, bankPlayer[num].count or 1, BankItems_ParseLink(bankPlayer[num].link))
							end
						end
					end
				end
				for _, bagNum in ipairs(BAGNUMBERS) do
					local theBag = bankPlayer[format("Bag%d", bagNum)]
					if searchFilter[bagNum] and theBag then
						local realSize = theBag.size
						if bagNum == 101  then
							realSize = #theBag
						elseif bagNum == 104 or bagNum == 105 then
							realSize = theBag.realSize or #theBag
						end
						for bagItem = 1, realSize do
							if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
								if BankItems_Save.ExportPrefix then
									if bagNum == 100 then
										prefix = "     "..L["Equipped"]..": "
									elseif bagNum == 101 then
										prefix = "     "..MINIMAP_TRACKING_MAILBOX..": "
									elseif bagNum == 102 then
										prefix = "     "..CURRENCY..": "
									elseif bagNum == 104 then
										prefix = "     "..VOID_STORAGE..": "
									elseif bagNum == 105 then
										prefix = "     "..REAGENT_BANK..": "
									else
										prefix = "     "..L["Bag %d Item %d:"]:format(bagNum, bagItem).." "
									end
								end
								temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag[bagItem].link, "%[(.*)%]")))
								if strfind(temp, searchText, 1, true) then
									count = count + 1
									if count == 1 then
										line = line + 1
										t[line] = L["Contents of:"].." "..gsub(key, "|", L[" of "])
									end
									line = line + 1
									t[line] = format("%s%d %s", prefix, theBag[bagItem].count or 1, BankItems_ParseLink(theBag[bagItem].link))
								end
							end
						end
						if type(theBag.link) == "string" then
							temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag.link, "%[(.*)%]")))
							if strfind(temp, searchText, 1, true) then
								count = count + 1
								if count == 1 then
									line = line + 1
									t[line] = L["Contents of:"].." "..gsub(key, "|", L[" of "])
								end
								line = line + 1
								t[line] = format("%s%d %s", prefix, 1, BankItems_ParseLink(theBag.link))
							end
						end
					end
				end
				if count > 0 then
					line = line + 1
					t[line] = ""
				end
			end
		end

		if BankItems_Save.Behavior2[5] then	-- Search guild banks too
			for key, bankPlayer in pairs(BankItems_SaveGuild) do
				local _, realm = strsplit("|", key)
				if type(bankPlayer) == "table" and (BankItems_Save.SearchAllRealms or (realm == selfPlayerRealm and bankPlayer.faction == selfPlayer.faction)) then
					count = 0
					for tab = 1, MAX_GUILDBANK_TABS do
						if bankPlayer[tab] and bankPlayer[tab].seen then
							-- Tab exists and seen before
							local theBag = bankPlayer[tab]
							for bagItem = 1, 98 do
								if theBag[bagItem] then
									if BankItems_Save.ExportPrefix then
										prefix = "     "..L["Tab %d Item %d:"]:format(tab, bagItem).." "
									end
									temp = BankItems_SpecialCharactersLocalization(strlower(strmatch(theBag[bagItem].link, "%[(.*)%]")))
									if strfind(temp, searchText, 1, true) then
										count = count + 1
										if count == 1 then
											line = line + 1
											t[line] = L["Contents of:"].." "..gsub(key, "(.*)|", "<%1>"..L[" of "])
										end
										line = line + 1
										t[line] = format("%s%d %s", prefix, theBag[bagItem].count or 1, BankItems_ParseLink(theBag[bagItem].link))
									end
								end
							end
						end
					end
				end
			end
		end
	end

	line = line + 1
	t[line] = "\n"..format(L[ [[Search for "%s" complete.]] ], searchTextOrg).."\n"

	BankItems_DisplaySearch()
	BankItems_ExportFrame_ScrollText:SetText(table.concat(t, "\n"))
	delTable(t)
end

function BankItems_DisplaySearch()
	BankItems_ExportFrame.mode = "search"
	BankItems_ExportFrame_ResetButton:SetText(SEARCH)
	BankItems_ExportFrame_SearchTextbox:Show()
	BankItems_ExportFrame_SearchAllRealms:Show()
	BankItems_ExportFrame_ShowBagPrefix:SetChecked(BankItems_Save.ExportPrefix)
	BankItems_ExportFrame_GroupData:SetChecked(BankItems_Save.GroupExportData)
	BankItems_ExportFrame_SearchAllRealms:SetChecked(BankItems_Save.SearchAllRealms)
	BankItems_ExportFrame_SearchDropDown:Show()
	BankItems_ExportFrame_Scroll:SetHeight(300)
	BankItems_ExportFrame_ScrollText:SetHeight(294)
	BankItems_ExportFrame:Show()
end

function BankItems_Hook_SendMail(recipient, subject, body)
	local subCount = 0
	-- Capitalize the first letter, lower the rest
	recipient = string.upper(strsub(recipient, 1, 1))..strsub(recipient, 2)
	recipient, subCount = recipient:gsub("-","|",1) --mail sent to character on another realm
	if subCount == 0 then recipient = recipient.."|"..selfPlayerRealm end --mail sent to character on own realm
	if BankItems_Save[recipient] then --realm is already formatted above
		-- Target recipient exists in our database, cache some data to be saved later if mail sending is successful
		mailItem.recipient = recipient
		for i = 1, ATTACHMENTS_MAX_SEND do
			mailItem[i] = mailItem[i] or newTable()
			local name, _, count = GetSendMailItem(i)
			mailItem[i].name, mailItem[i].count = name, count and count > 1 and count or nil
			mailItem[i].link = GetSendMailItemLink(i)
			mailItem[i].returned = true
			mailItem[i].deleted = nil
		end
		if GetSendMailCOD() > 0 then
			mailItem.money = 0
			mailItem.CoD = true
		else
			mailItem.money = GetSendMailMoney()
			mailItem.CoD = false
		end
		BankItems_Frame:RegisterEvent("MAIL_SEND_SUCCESS")
	end
end
hooksecurefunc("SendMail", BankItems_Hook_SendMail)

function BankItems_Frame_MailSendSuccess()
	local targetPlayer = BankItems_Save[mailItem.recipient]
	targetPlayer.Bag101 = targetPlayer.Bag101 or newTable()
	local targetBag = targetPlayer.Bag101
	targetBag.icon = ICON_Mailbox

	for i = ATTACHMENTS_MAX_SEND, 1, -1 do
		if mailItem[i].name then
			local data = newTable()
			data.link = mailItem[i].link
			data.count = mailItem[i].count
			data.returned = mailItem[i].returned
			data.deleted = mailItem[i].deleted
			if mailItem.CoD then
				data.expiry = time() + 3*60*60*24
			else
				data.expiry = time() + 30*60*60*24
			end
			tinsert(targetBag, 1, data)
		end
	end
	if mailItem.money ~= 0 then
		if #targetBag == 0 or type(targetBag[#targetBag].link) == "string" then
			local data = newTable()
			data.link = mailItem.money
			data.icon = GetCoinIcon(mailItem.money)
			tinsert(targetBag, data)
		elseif type(targetBag[#targetBag].link) == "number" then
			local data = targetBag[#targetBag]
			data.link = data.link + mailItem.money
			data.icon = GetCoinIcon(data.link)
		end
	end

	-- Size of mailbag is min 4, max 18, multiple of 2
	targetBag.size = min(max(4, #targetBag + #targetBag % 2), 18)

	if bankPlayer == targetPlayer and BagContainerAr[101] and BagContainerAr[101]:IsVisible() then
		BagContainerAr[101]:Hide()
		BagButtonAr[101]:Click()
	end
end

local BankItems_Orig_ReturnInboxItem = ReturnInboxItem
function ReturnInboxItem(index, ...)
	local subCount = 0
	local _, _, recipient, _, money, CODAmount, _, hasItem = GetInboxHeaderInfo(index)
	if recipient then recipient, subCount = recipient:gsub("-","|",1) end --mail sent to character on connected realm
	if recipient and subCount == 0 then recipient = recipient.."|"..selfPlayerRealm end --mail sent to character on own realm
	if recipient and BankItems_Save[recipient] then --realm is already formatted above
		-- Target recipient exists in our database, set some data to be saved
		mailItem.recipient = recipient
		for i = 1, ATTACHMENTS_MAX_SEND do
			mailItem[i] = mailItem[i] or newTable()
			local name, _, count = GetInboxItem(index, i)
			mailItem[i].name, mailItem[i].count = name, count and count > 1 and count or nil
			mailItem[i].link = GetInboxItemLink(index, i)
			mailItem[i].returned = nil
			mailItem[i].deleted = true
		end
		mailItem.money = money
		BankItems_Frame_MailSendSuccess()
		BankItems_Generate_ItemCache()
	end
	return BankItems_Orig_ReturnInboxItem(index, ...)
end
--hooksecurefunc("ReturnInboxItem", BankItems_Hook_ReturnInboxItem)

-- Public function called during cache generation.
-- It can be used by other addons as hook point to catch item names
-- and corresponding item ids stored in Bank Item cache tables.
-- To get item name you can use: itemName = strmatch(link,"|h%[([^%]]+)%]|h|r$")
function BankItems_Cache_ItemName(itemId, link)
end

function BankItems_Generate_ItemCache()
	-- This function generates an item cache that contains everything all players except the current player on the current realm
	if not BankItems_Save.TooltipInfo then return end
	local temp
	local data = newTable()
	for key, bankPlayer in pairs(BankItems_Save) do
		local _, realm = strsplit("|", key)
		if type(bankPlayer) == "table" and selfPlayer ~= bankPlayer and (BankItems_Save.ShowAllRealms or (realm == selfPlayerRealm and (BankItems_Save.ShowOppositeFaction or bankPlayer.faction == selfPlayer.faction))) and key ~= "Behavior" and key ~= "Behavior2" then
			BankItems_FactionCache[key] = bankPlayer.faction
			for num = 1, NUM_BANKGENERIC_SLOTS do
				if bankPlayer[num] then
					--temp = strmatch(bankPlayer[num].link, "%[(.*)%]")
					temp = tonumber(strmatch(bankPlayer[num].link, "item:(%d+):"))
					if temp then
						BankItems_Cache_ItemName(temp, bankPlayer[num].link)
						data[temp] = data[temp] or newTable()
						data[temp][key] = data[temp][key] or newTable()
						data[temp][key].count = (data[temp][key].count or 0) + (bankPlayer[num].count or 1)
						data[temp][key].bank = (data[temp][key].bank or 0) + (bankPlayer[num].count or 1)
					end
				end
			end
			for _, bagNum in ipairs(BAGNUMBERS) do
				local theBag = bankPlayer[format("Bag%d", bagNum)]
				if theBag then
					local realSize = theBag.size
					if bagNum == 101 or bagNum == 103 then
						realSize = #theBag
					elseif bagNum == 104 or bagNum == 105 then
						realSize = theBag.realSize or #theBag
					end
					for bagItem = 1, realSize do
						if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
							--temp = strmatch(theBag[bagItem].link, "%[(.*)%]")
							temp = tonumber(strmatch(theBag[bagItem].link, "item:(%d+):"))
							if not temp then
								temp = strmatch(theBag[bagItem].link, "(currency:%d+)")
							end
							if temp then
								BankItems_Cache_ItemName(temp, theBag[bagItem].link)
								data[temp] = data[temp] or newTable()
								data[temp][key] = data[temp][key] or newTable()
								data[temp][key].count = (data[temp][key].count or 0) + (theBag[bagItem].count or 1)
								if bagNum >= 0 and bagNum <= 4 then
									data[temp][key].inv = (data[temp][key].inv or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 100 then
									data[temp][key].equipped = (data[temp][key].equipped or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 101 then
									data[temp][key].mail = (data[temp][key].mail or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 102 then
									data[temp][key].currency = (data[temp][key].currency or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 103 then
									data[temp][key].auction = (data[temp][key].auction or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 104 then
									data[temp][key].voidstorage = (data[temp][key].voidstorage or 0) + (theBag[bagItem].count or 1)
								elseif bagNum == 105 then
									data[temp][key].reagentbank = (data[temp][key].reagentbank or 0) + (theBag[bagItem].count or 1)
								else
									data[temp][key].bank = (data[temp][key].bank or 0) + (theBag[bagItem].count or 1)
								end
							end
						end
					end
				end
			end
		end
	end
	delTable(BankItems_Cache)
	BankItems_Cache = data
	delTable(BankItems_TooltipCache)
	BankItems_TooltipCache = newTable()
end

function BankItems_Generate_SelfItemCache()
	-- This function generates an item cache with only the player's items
	if not BankItems_Save.TooltipInfo then return end
	local temp
	local data = newTable()
	local bankPlayer = selfPlayer
	for num = 1, NUM_BANKGENERIC_SLOTS do
		if bankPlayer[num] then
			--temp = strmatch(bankPlayer[num].link, "%[(.*)%]")
			temp = tonumber(strmatch(bankPlayer[num].link, "item:(%d+):"))
			if temp then
				BankItems_Cache_ItemName(temp, bankPlayer[num].link)
				data[temp] = data[temp] or newTable()
				data[temp].count = (data[temp].count or 0) + (bankPlayer[num].count or 1)
				data[temp].bank = (data[temp].bank or 0) + (bankPlayer[num].count or 1)
			end
		end
	end
	for _, bagNum in ipairs(BAGNUMBERS) do
		local theBag = bankPlayer[format("Bag%d", bagNum)]
		if theBag then
			local realSize = theBag.size
			if bagNum == 101 or bagNum == 103 then
				realSize = #theBag
			elseif bagNum == 104 or bagNum == 105 then
				realSize = theBag.realSize or #theBag
			end

			--print("Generating cache for: "..format("Bag%d", bagNum));
			--print("bag size: "..format("%d", realSize or 0));
			for bagItem = 1, realSize do
				if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
					--temp = strmatch(theBag[bagItem].link, "%[(.*)%]")
					temp = tonumber(strmatch(theBag[bagItem].link, "item:(%d+):"))
					if not temp then
						temp = strmatch(theBag[bagItem].link, "(currency:%d+)")
					end
					if temp then
						BankItems_Cache_ItemName(temp, theBag[bagItem].link)
						data[temp] = data[temp] or newTable()
						data[temp].count = (data[temp].count or 0) + (theBag[bagItem].count or 1)
						if bagNum >= 0 and bagNum <= 4 then
							data[temp].inv = (data[temp].inv or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 100 then
							data[temp].equipped = (data[temp].equipped or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 101 then
							data[temp].mail = (data[temp].mail or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 102 then
							data[temp].currency = (data[temp].currency or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 103 then
							data[temp].auction = (data[temp].auction or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 104 then
							data[temp].voidstorage = (data[temp].voidstorage or 0) + (theBag[bagItem].count or 1)
						elseif bagNum == 105 then
							data[temp].reagentbank = (data[temp].reagentbank or 0) + (theBag[bagItem].count or 1)
						else
							data[temp].bank = (data[temp].bank or 0) + (theBag[bagItem].count or 1)
						end
					end
				end
			end
		end
	end
	delTable(BankItems_SelfCache)
	BankItems_SelfCache = data
	delTable(BankItems_TooltipCache)
	BankItems_TooltipCache = newTable()
end

function BankItems_Generate_GuildItemCache()
	-- This function generates an item cache that contains all guilds on the current realm
	if not BankItems_Save.TooltipInfo then return end
	local temp
	local data = newTable()

	for key, bankPlayer in pairs(BankItems_SaveGuild) do
		local _, realm = strsplit("|", key)
		if bankPlayer.track and (BankItems_Save.ShowAllRealms or (realm == selfPlayerRealm and (BankItems_Save.ShowOppositeFaction or bankPlayer.faction == selfPlayer.faction))) then
			BankItems_GFactionCache[key] = bankPlayer.faction
			for tab = 1, MAX_GUILDBANK_TABS do
				if bankPlayer[tab] and bankPlayer[tab].seen then
					-- Tab exists and seen before
					local theBag = bankPlayer[tab]
					for bagItem = 1, 98 do
						if theBag[bagItem] then
							--temp = strmatch(theBag[bagItem].link, "%[(.*)%]")
							temp = tonumber(strmatch(theBag[bagItem].link, "item:(%d+):"))
							if temp then
								BankItems_Cache_ItemName(temp,theBag[bagItem].link)
								data[temp] = data[temp] or newTable()
								data[temp][key] = data[temp][key] or newTable()
								data[temp][key].count = (data[temp][key].count or 0) + (theBag[bagItem].count or 1)
								data[temp][key].gbank = (data[temp][key].gbank or 0) + (theBag[bagItem].count or 1)
							end
						end
					end
				end
			end
		end
	end

	delTable(BankItems_GuildCache)
	BankItems_GuildCache = data
	delTable(BankItems_TooltipCache)
	BankItems_TooltipCache = newTable()
end

function BankItems_AddTooltipData(self, ...)
	if not BankItems_Save.TooltipInfo or self.BankItemsDone then return end

	local _, item = self:GetItem()
	item = item and tonumber(item:match("item:(%d+):"))
	if not item then item = self.BankItemsIsCurrency end
	if not item then return end

	if not BankItems_TooltipCache[item] then
		BankItems_TooltipCache[item] = newTable()

		if item == 6948 or item == 110560 then--Ignore Hearthstone and Garrison Hearthstone
			self.BankItemsDone = true
			return
		end

		local baginfos = {
			{ L["Bank"] },
			{ L["Bags"] },
			{ L["Equipped"] },
			{ MAIL_LABEL },
			{ AUCTIONS },
			{ CURRENCY },
			{ VOID_STORAGE },
			{ REAGENT_BANK }
		}
		local totalCount = 0
		local characters = 0
		if BankItems_SelfCache[item] then
			local text
			local counttable = BankItems_SelfCache[item]
			totalCount = totalCount + counttable.count

			baginfos[1][2] = counttable.bank
			baginfos[2][2] = counttable.inv
			baginfos[3][2] = counttable.equipped
			baginfos[4][2] = counttable.mail
			baginfos[5][2] = counttable.auction
			baginfos[6][2] = counttable.currency
			baginfos[7][2] = counttable.voidstorage
			baginfos[8][2] = counttable.reagentbank
			text = format("%s %s %d [", strsplit("|", selfPlayerName), L["has"], counttable.count);
			local first = true
			for i = 1, #baginfos do
				if baginfos[i][2] then
					if not first then text = text..", " end
					text = text..baginfos[i][1].." "..baginfos[i][2]
					first = false
				end
			end
			text = text.."]"
			tinsert(BankItems_TooltipCache[item], text)
			characters = characters + 1
		end
		if BankItems_Cache[item] then
			for who, counttable in pairs(BankItems_Cache[item]) do
				local text
				local name
				local n, r = strsplit("|", who)
				if selfPlayerRealm ~= r then
					name = n.."-"..r
				else
					name = n
				end
				if BankItems_FactionCache[who] ~= selfPlayer.faction then
					name = name.."*"
				end
				totalCount = totalCount + counttable.count

				baginfos[1][2] = counttable.bank
				baginfos[2][2] = counttable.inv
				baginfos[3][2] = counttable.equipped
				baginfos[4][2] = counttable.mail
				baginfos[5][2] = counttable.auction
				baginfos[6][2] = counttable.currency
				baginfos[7][2] = counttable.voidstorage
				baginfos[8][2] = counttable.reagentbank
				text = format("%s %s %d [", name, L["has"], counttable.count);
				local first = true
				for i = 1, #baginfos do
					if baginfos[i][2] then
						if not first then text = text..", " end
						text = text..baginfos[i][1].." "..baginfos[i][2]
						first = false
					end
				end
				text = text.."]"
				tinsert(BankItems_TooltipCache[item], text)
				characters = characters + 1
			end
		end
		if BankItems_GuildCache[item] then
			for who, counttable in pairs(BankItems_GuildCache[item]) do
				local n, r = strsplit("|", who)
				local name
				local n, r = strsplit("|", who)
				if selfPlayerRealm ~= r then
					name = n.."-"..r
				else
					name = n
				end
				if BankItems_GFactionCache[who] ~= selfPlayer.faction then
					name = name.."*"
				end
				local text = ("<%s> %s %d [%s %d]"):format(name, L["has"], counttable.count, GUILD_BANK, counttable.gbank)
				totalCount = totalCount + counttable.count
				tinsert(BankItems_TooltipCache[item], text)
				characters = characters + 1
			end
		end
		if characters > 1 then
			tinsert(BankItems_TooltipCache[item], L["Total: %d"]:format(totalCount))
		end
	end
	local num = #BankItems_TooltipCache[item]
	if num > 0 then
		for i = 1, num do
			self:AddLine(BankItems_TooltipCache[item][i], 0.2890625, 0.6953125, 0.8359375)
		end
		self:Show()
	end
	self.BankItemsDone = true
end

function BankItems_ClearTooltipData(self)
	-- Credits to Siz on this code
	self.BankItemsDone = nil
end

function BankItems_Hooktooltip(tooltip)
	-- Use nonsecure hooks and upvalues for speed
	local a = tooltip:GetScript("OnTooltipSetItem")
	if a then
		tooltip:SetScript("OnTooltipSetItem", function(self, ...)
			BankItems_AddTooltipData(self, ...)
			return a(self, ...)
		end)
	else
		tooltip:SetScript("OnTooltipSetItem", BankItems_AddTooltipData)
	end
	local b = tooltip:GetScript("OnTooltipCleared")
	if b then
		tooltip:SetScript("OnTooltipCleared", function(self, ...)
			-- Credits to Siz on this code
			self.BankItemsDone = nil
			return b(self, ...)
		end)
	else
		tooltip:SetScript("OnTooltipCleared", BankItems_ClearTooltipData)
	end

	-- Hook some functions...
	local c = tooltip.SetCurrencyByID
	tooltip.SetCurrencyByID = function(self, ...)
		c(self, ...)
		tooltip.BankItemsIsCurrency = "currency:"..(...)
		BankItems_AddTooltipData(self)
		tooltip.BankItemsIsCurrency = nil
	end

	local d = tooltip.SetCurrencyToken
	tooltip.SetCurrencyToken = function(self, ...)
		d(self, ...)
		local link = GetCurrencyListLink(...)
		tooltip.BankItemsIsCurrency = strmatch(link, "(currency:%d+)")
		BankItems_AddTooltipData(self)
		tooltip.BankItemsIsCurrency = nil
	end

	local e = tooltip.SetHyperlink
	tooltip.SetHyperlink = function(self, ...)
		e(self, ...)
		tooltip.BankItemsIsCurrency = strmatch(..., "(currency:%d+)")
		BankItems_AddTooltipData(self)
		tooltip.BankItemsIsCurrency = nil
	end
	
	local f = tooltip.SetCurrencyTokenByID
	tooltip.SetCurrencyTokenByID = function(self, ...)
		f(self, ...)
		tooltip.BankItemsIsCurrency = "currency:"..(...)
		BankItems_AddTooltipData(self)
		tooltip.BankItemsIsCurrency = nil
	end
end

function BankItems_HookTooltips()
	-- Walk through all frames
	local tooltip = EnumerateFrames()
	while tooltip do
		if tooltip:GetObjectType() == "GameTooltip" then
			local name = tooltip:GetName()
			if name then
				for i = 1, #TooltipList do
					if strfind(name, TooltipList[i], 1, true) then
						BankItems_Hooktooltip(tooltip)
						break
					end
				end
			end
		end
		tooltip = EnumerateFrames(tooltip)
	end
	if LinkWrangler then
		LinkWrangler.RegisterCallback("BankItems", BankItems_Hooktooltip, "allocate")
	end
	-- Kill function so that it won't get called twice (causing double hooking)
	BankItems_HookTooltips = function() end
end

-- Add slash command
SlashCmdList["BANKITEMS"] = BankItems_SlashHandler
SLASH_BANKITEMS1 = "/bankitems"
SLASH_BANKITEMS2 = "/bi"

SlashCmdList["BANKITEMSSEARCH"] = function(msg)
	if msg and #msg > 0 then
		BankItems_SlashHandler("search "..msg)
	else
		BankItems_DisplaySearch()
	end
end
SLASH_BANKITEMSSEARCH1 = "/bis"

-- Makes ESC key close BankItems
tinsert(UISpecialFrames, "BankItems_Frame")
tinsert(UISpecialFrames, "BankItems_ExportFrame")


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Guild Bank Stuff

function BankItems_DisplayGuildBank()
	if BankItems_GBFrame:IsVisible() then
		HideUIPanel(BankItems_GBFrame)
	else
		ShowUIPanel(BankItems_GBFrame)
	end
end

function BankItems_SaveGuildBankItems()
	-- This function saves the contents of the CURRENT guild bank tab. The server only
	-- sends data 1 guild bank tab at a time since each tab may have different view permissions.
	if isGuildBankOpen then
		local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals
		local numTabs = GetNumGuildBankTabs()

		local selfGuildRealm = strtrim(GetRealmName())
		local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
		if not BankItems_SaveGuild[selfGuildName] then
			BankItems_SaveGuild[selfGuildName] = newTable()
		end
		local selfGuild = BankItems_SaveGuild[selfGuildName]
		selfGuild.numTabs = numTabs
		selfGuild.faction = UnitFactionGroup("player")
		BankItems_GuildDropdownGenerateKeys()

		local i = GetCurrentGuildBankTab()
		if i <= numTabs then
			name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(i)
			if not name or name == "" then
				name = format(GUILDBANK_TAB_NUMBER, i)
			end
			-- Save this tab
			selfGuild[i] = selfGuild[i] or newTable()
			selfGuild[i].name = name
			selfGuild[i].icon = icon
			if isViewable then
				selfGuild[i].seen = date()	-- This flag indicates the user has seen the contents of this tab at least once.
				for j = 1, 98 do
					itemLink = GetGuildBankItemLink(i, j)
					if itemLink then
						selfGuild[i][j] = selfGuild[i][j] or newTable()
						local _, count = GetGuildBankItemInfo(i, j)
						selfGuild[i][j].count = count and count > 1 and count or nil
						selfGuild[i][j].link = itemLink
					else
						selfGuild[i][j] = delTable(selfGuild[i][j])
					end
				end
			end
		end

		if BankItems_GBFrame:IsVisible() and BankItems_GuildDropdown.selectedValue == selfGuildName and BankItems_GBFrame.currentTab == i then
			BankItems_PopulateGuildBank(BankItems_GuildDropdown.selectedValue, BankItems_GBFrame.currentTab)
		end
	end
end

function BankItems_SaveGuildBankTabs()
	if isGuildBankOpen then
		local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals
		local numTabs = GetNumGuildBankTabs()

		local selfGuildRealm = strtrim(GetRealmName())
		local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
		if not BankItems_SaveGuild[selfGuildName] then
			BankItems_SaveGuild[selfGuildName] = newTable()
			BankItems_GuildDropdownGenerateKeys()
		end
		local selfGuild = BankItems_SaveGuild[selfGuildName]
		selfGuild.numTabs = numTabs

		for i = 1, MAX_GUILDBANK_TABS do
			name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(i)
			if not name or name == "" then
				name = format(GUILDBANK_TAB_NUMBER, i)
			end
			if i > numTabs then
				-- Delete this tab
				selfGuild[i] = delTable(selfGuild[i])
			else
				-- Save this tab
				selfGuild[i] = selfGuild[i] or newTable()
				selfGuild[i].name = name
				selfGuild[i].icon = icon
			end
		end

		if BankItems_GBFrame:IsVisible() and BankItems_GuildDropdown.selectedValue == selfGuildName then
			BankItems_PopulateGuildTabs(BankItems_GuildDropdown.selectedValue)
		end
	end
end

function BankItems_SaveGuildBankMoney()
	if isGuildBankOpen then
		local selfGuildRealm = strtrim(GetRealmName())
		local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
		if not BankItems_SaveGuild[selfGuildName] then
			BankItems_SaveGuild[selfGuildName] = newTable()
			BankItems_GuildDropdownGenerateKeys()
		end
		BankItems_SaveGuild[selfGuildName].money = GetGuildBankMoney()

		if BankItems_GBFrame:IsVisible() and BankItems_GuildDropdown.selectedValue == selfGuildName then
			MoneyFrame_Update("BankItems_GBFrame_MoneyFrame", BankItems_SaveGuild[BankItems_GuildDropdown.selectedValue].money)
			BankItems_GBFrame_MoneyFrame:Show()
		end
	end
end

function BankItems_SaveGuildBankTabard()
	if isGuildBankOpen then
		local selfGuildRealm = strtrim(GetRealmName())
		local selfGuildName = GetGuildInfo("player").."|"..selfGuildRealm
		if not BankItems_SaveGuild[selfGuildName] then
			BankItems_SaveGuild[selfGuildName] = newTable()
			BankItems_GuildDropdownGenerateKeys()
		end

		local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFileNames()
		if not tabardEmblemUpper then
			tabardBackgroundUpper = "Textures\\GuildEmblems\\Background_49_TU_U"
			tabardBackgroundLower = "Textures\\GuildEmblems\\Background_49_TL_U"
		end

		local t = BankItems_SaveGuild[selfGuildName]
		t.tabard = t.tabard or newTable()
		t.tabard[1] = tabardBackgroundUpper
		t.tabard[2] = tabardBackgroundLower
		t.tabard[3] = tabardEmblemUpper
		t.tabard[4] = tabardEmblemLower
		t.tabard[5] = tabardBorderUpper
		t.tabard[6] = tabardBorderLower
	end
	if BankItems_GBFrame:IsVisible() and BankItems_GuildDropdown.selectedValue == selfGuildName then
		BankItems_PopulateGuildTabard(selfGuildName)
	end
end

function BankItems_GuildDropdownGenerateKeys()
	for k, v in pairs(sortedGuildKeys) do
		sortedGuildKeys[k] = nil
	end
	for key, value in pairs(BankItems_SaveGuild) do
		if type(value) == "table" then
			local _, realm = strsplit("|", key)
			if BankItems_Save.ShowAllRealms or (realm == selfPlayerRealm and (BankItems_Save.ShowOppositeFaction or value.faction == selfPlayer.faction)) then
				tinsert(sortedGuildKeys, key)
			end
		end
	end
	-- Reuse user sort function, it has the same functionality
	table.sort(sortedGuildKeys, BankItems_UserDropdown_Sort)
end

function BankItems_GuildDropdown_Initialize()
	for _, key in ipairs(sortedGuildKeys) do
		local f = BankItems_SaveGuild[key].faction
		if f == "Alliance" then f = FACTION_ALLIANCE
		elseif f == "Horde" then f = FACTION_HORDE
		else f = UNKNOWN
		end
		info.text = gsub(key, "(.*)|", "<%1>"..L[" of "]).." ("..f..")"
		info.arg1 = key
		info.arg2 = gsub(key, "(.*)|", "<%1>"..L[" of "])
		info.func = BankItems_GuildDropdown_OnClick
		info.checked = (BankItems_GuildDropdown.selectedValue == info.arg1)
		info.keepShownOnClick = nil
		info.isNotRadio = 1
		UIDropDownMenu_AddButton(info)
	end
end

function BankItems_GuildDropdown_OnClick(button, guildName, text)
	text = text or gsub(guildName, "(.*)|", "<%1>"..L[" of "])
	CloseDropDownMenus()
	BankItems_GuildDropdownText:SetText(text)
	BankItems_GuildDropdown.selectedValue = guildName
	BankItems_GBFrame.currentTab = nil
	BankItems_GBFrame_OnShow()
end

function BankItems_PopulateGuildBank(guildName, tab)
	local selfGuild = BankItems_SaveGuild[guildName]
	tab = tab or 1
	BankItems_GBFrame.currentTab = tab
	if selfGuild[tab] then
		-- Tab exists
		if selfGuild[tab].seen then
			-- Tab has been seen before
			BankItems_GBFrame.title:SetText(selfGuild[tab].name.." |cFFFFFFFF("..selfGuild[tab].seen..")")
			BankItems_GBFrame.infotext:Hide()
			for i = 1, 7 do
				BankItems_GBFrame.colbg[i]:Show()
			end
			for i = 1, 98 do
				if selfGuild[tab][i] then
					-- Item exists
					local quality = select(3, GetItemInfo(selfGuild[tab][i].link))
					if quality and (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
						GBButtonAr[i].IconBorder:Show()
						GBButtonAr[i].IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
					else
						GBButtonAr[i].IconBorder:Hide()
					end
					GBButtonAr[i].icon:SetTexture(GetItemIcon(selfGuild[tab][i].link))
					if selfGuild[tab][i].count then
						GBButtonAr[i].Count:Show()
						GBButtonAr[i].Count:SetText(selfGuild[tab][i].count)
					else
						GBButtonAr[i].Count:Hide()
					end
				else
					-- Item doesn't exist
					GBButtonAr[i].icon:SetTexture()
					GBButtonAr[i].IconBorder:Hide()
					GBButtonAr[i].Count:Hide()
				end
				GBButtonAr[i]:Show()
			end
			BankItems_FilterBags()
		else
			-- Tab hasn't been seen before, but exists
			BankItems_GBFrame.title:SetText(selfGuild[tab].name.." |cFFFFFFFF"..L["(Not seen before)"])
			BankItems_GBFrame.infotext:SetFormattedText(L[ [[You have not seen the contents of "%s" before]] ], selfGuild[tab].name)
			BankItems_GBFrame.infotext:Show()
			for i = 1, 7 do
				BankItems_GBFrame.colbg[i]:Hide()
			end
			for i = 1, 98 do
				GBButtonAr[i]:Hide()
			end
		end
		BankItems_GBFrame.titlebg:SetWidth(BankItems_GBFrame.title:GetWidth()+20)
		for i = 1, MAX_GUILDBANK_TABS do
			if i == tab then
				GBTabFrameAr[i].button:SetChecked(1)
			else
				GBTabFrameAr[i].button:SetChecked(nil)
			end
		end
	else
		-- This guild has no bank tabs
		BankItems_GBFrame.title:SetText(L["No Guild Bank Tabs"])
		BankItems_GBFrame.titlebg:SetWidth(BankItems_GBFrame.title:GetWidth()+20)
		for i = 1, 7 do
			BankItems_GBFrame.colbg[i]:Hide()
		end
		for i = 1, 98 do
			GBButtonAr[i]:Hide()
		end
		BankItems_GBFrame.currentTab = nil
		BankItems_GBFrame.infotext:SetFormattedText(L["<%s>'s guild bank has not purchased any guild bank tabs."], strmatch(guildName, "(.*)|"))
		BankItems_GBFrame.infotext:Show()
	end
end

function BankItems_PopulateGuildTabs(guildName)
	local selfGuild = BankItems_SaveGuild[guildName]
	for i = 1, MAX_GUILDBANK_TABS do
		if selfGuild[i] then
			local icon = selfGuild[i].icon
			if tonumber(icon) then
				GBTabFrameAr[i].button.texture:SetToFileData(icon)
			else
				GBTabFrameAr[i].button.texture:SetTexture(icon)
			end
			GBTabFrameAr[i]:Show()
		else
			GBTabFrameAr[i]:Hide()
		end
	end
end

function BankItems_PopulateGuildTabard(guildName)
	local t = BankItems_SaveGuild[guildName].tabard
	BankItems_GBEmblemFrame.bgUL:SetTexture(t[1])
	BankItems_GBEmblemFrame.bgUR:SetTexture(t[1])
	BankItems_GBEmblemFrame.bgBL:SetTexture(t[2])
	BankItems_GBEmblemFrame.bgBR:SetTexture(t[2])
	BankItems_GBEmblemFrame.bdUL:SetTexture(t[3])
	BankItems_GBEmblemFrame.bdUR:SetTexture(t[3])
	BankItems_GBEmblemFrame.bdBL:SetTexture(t[4])
	BankItems_GBEmblemFrame.bdBR:SetTexture(t[4])
	BankItems_GBEmblemFrame.UL:SetTexture(t[5])
	BankItems_GBEmblemFrame.UR:SetTexture(t[5])
	BankItems_GBEmblemFrame.BL:SetTexture(t[6])
	BankItems_GBEmblemFrame.BR:SetTexture(t[6])
	BankItems_GBEmblemFrame:Show()
end

function BankItems_GenerateGuildExportText()
	local guildName = BankItems_GuildDropdown.selectedValue
	local selfGuild = BankItems_SaveGuild[guildName]
	local t = newTable()
	local line = 1
	t[1] = L["Contents of:"].." "..gsub(guildName, "(.*)|", "<%1>"..L[" of "]).."\n"
	local prefix = ""
	local errorflag = false
	BankItems_ExportFrame.mode = "exportguild"
	BankItems_ExportFrame_ResetButton:SetText(RESET)
	BankItems_ExportFrame_SearchTextbox:Hide()
	BankItems_ExportFrame_SearchAllRealms:Hide()
	BankItems_ExportFrame_ShowBagPrefix:SetChecked(BankItems_Save.ExportPrefix)
	BankItems_ExportFrame_GroupData:SetChecked(BankItems_Save.GroupExportData)
	BankItems_ExportFrame_SearchDropDown:Hide()
	BankItems_ExportFrame_Scroll:SetHeight(310)
	BankItems_ExportFrame_ScrollText:SetHeight(304)

	if BankItems_Save.GroupExportData then
		-- Group similar items together in the report
		local data = newTable()
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture

		for tab = 1, MAX_GUILDBANK_TABS do
			if selfGuild[tab] and selfGuild[tab].seen then
				-- Tab exists and seen before
				local theBag = selfGuild[tab]
				for bagItem = 1, 98 do
					if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
						itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(theBag[bagItem].link)
						if itemType then
							data[itemType] = data[itemType] or newTable()
							data[itemType][itemName] = (data[itemType][itemName] or 0) + (theBag[bagItem].count or 1)
						else
							errorflag = true
						end
					end
				end
			end
		end

		-- Generate the report
		for itemType, items in pairs(data) do
			line = line + 1
			t[line] = itemType
			for itemName, count in pairs(items) do
				line = line + 1
				t[line] = format("%d %s", count, itemName)
			end
			line = line + 1
			t[line] = ""
		end
		if errorflag then
			line = line + 1
			t[line] = L["BANKITEMS_CAUTION_TEXT"]
		end
		delTable(data)
	else
		-- Don't group similar items together in the report
		for tab = 1, MAX_GUILDBANK_TABS do
			if selfGuild[tab] and selfGuild[tab].seen then
				-- Tab exists and seen before
				local theBag = selfGuild[tab]
				for bagItem = 1, 98 do
					if theBag[bagItem] and type(theBag[bagItem].link) == "string" then
						if BankItems_Save.ExportPrefix then
							prefix = format(L["Tab %d Item %d:"], tab, bagItem).." "
						end
						line = line + 1
						t[line] = format("%s%d %s", prefix, theBag[bagItem].count or 1, BankItems_ParseLink(theBag[bagItem].link))
					end
				end
			end
		end
	end

	if selfGuild.money then
		line = line + 1
		t[line] = "\n"..L["Money:"].." "..BankItem_ParseMoney(selfGuild.money).."\n"
	end

	BankItems_ExportFrame_ScrollText:SetText(table.concat(t, "\n"))
	delTable(t)
end

function BankItems_GBSlashHandler(msg)
	BankItems_CreateFrames()
	msg = strtrim(strlower(msg or ""))

	if msg == "clear" then
		local playerName = BankItems_GuildDropdown.selectedValue
		if BankItems_GBFrame:IsVisible() and playerName then
			BankItems_SaveGuild[playerName] = delTable(BankItems_SaveGuild[playerName])
			BankItems_GuildDropdownGenerateKeys()
			BankItems_GuildDropdown.selectedValue = nil
			BankItems_GBFrame_OnShow()
			BankItems_Generate_GuildItemCache()
		end
		return
	elseif msg == "" then
		BankItems_DisplayGuildBank()
		return
	else
		-- Invalid option, show relevant help text
		BankItems_Chat(BANKITEMS_VERSIONTEXT)
		BankItems_Chat(L["-- /bigb : open BankItems guild bank"])
		BankItems_Chat(L["-- /bigb clear : clear currently selected guild's info"])
		return
	end
end

-- Add slash command
SLASH_BANKITEMSGB1 = "/bigb"
SLASH_BANKITEMSGB2 = "/bankitemsgb"
SlashCmdList["BANKITEMSGB"] = BankItems_GBSlashHandler

-- Makes ESC key close BankItems Guild Bank, Reagent Bank, and Void Storage
tinsert(UISpecialFrames, "BankItems_GBFrame")
tinsert(UISpecialFrames, "BankItems_RBFrame")
tinsert(UISpecialFrames, "BankItems_VoidFrame")

do
	local temp, temp2, temp3

	-- Add Guild Banks button to BankItems main window
	temp = CreateFrame("Button", "BankItems_GuildBankButton", BankItems_Frame, "GameMenuButtonTemplate")
	temp:SetWidth(80)
	temp:SetHeight(20)
	temp:SetPoint("TOPLEFT", 80, -49)
	temp:SetText(GUILD_BANK)
	temp:SetScript("OnClick", BankItems_DisplayGuildBank)
	temp:SetNormalFontObject("GameFontHighlightSmall")
	temp:SetHighlightFontObject("GameFontHighlightSmall")
	temp:SetDisabledFontObject("GameFontDisableSmall")
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Reagent Bank Stuff

function BankItems_DisplayReagentBank()
	if BankItems_RBFrame:IsVisible() then
		HideUIPanel(BankItems_RBFrame)
	else
		ShowUIPanel(BankItems_RBFrame)
	end
end

function BankItems_PopulateReagentBank()
	if BankItems_Save.reagentBags then return end
	if bankPlayer.Bag105 then
		-- Reagent Bank has been seen before
		BankItems_RBFrame.TitleText:SetText(REAGENT_BANK.." - "..gsub(bankPlayerName, "|", L[" of "]))
		BankItems_RBFrame.infotext:Hide()
		for i = 1, 7 do
			BankItems_RBFrame.colShadow[i]:Show()
			BankItems_RBFrame.colbg[i]:Show()
		end
		for i = 1, 98 do
			if bankPlayer.Bag105[i] then
				-- Item exists
				local quality = select(3, GetItemInfo(bankPlayer.Bag105[i].link))
				if quality and (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					RBButtonAr[i].IconBorder:Show()
					RBButtonAr[i].IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
				else
					RBButtonAr[i].IconBorder:Hide()
				end
				RBButtonAr[i].icon:SetTexture(GetItemIcon(bankPlayer.Bag105[i].link))
				if bankPlayer.Bag105[i].count then
					RBButtonAr[i].Count:Show()
					RBButtonAr[i].Count:SetText(bankPlayer.Bag105[i].count)
				else
					RBButtonAr[i].Count:Hide()
				end
			else
				-- Item doesn't exist
				RBButtonAr[i].icon:SetTexture()
				RBButtonAr[i].IconBorder:Hide()
				RBButtonAr[i].Count:Hide()
			end
			RBButtonAr[i]:Show()
		end
		BankItems_FilterBags()
	else
		-- Reagent Bank hasn't been seen before
		BankItems_RBFrame.TitleText:SetText(REAGENT_BANK.." - "..gsub(bankPlayerName, "|", L[" of "]).." |cFFFFFFFF"..L["(Not seen before)"])
		BankItems_RBFrame.infotext:SetFormattedText(L["%s data not found. Please log on this character."]:format(REAGENT_BANK))
		BankItems_RBFrame.infotext:Show()
		for i = 1, 7 do
			BankItems_RBFrame.colbg[i]:Hide()
			BankItems_RBFrame.colShadow[i]:Hide()
		end
		for i = 1, 98 do
			RBButtonAr[i]:Hide()
		end
	end
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Void Storage Stuff

function BankItems_DisplayVoidStorage()
	if BankItems_VoidFrame:IsVisible() then
		HideUIPanel(BankItems_VoidFrame)
	else
		ShowUIPanel(BankItems_VoidFrame)
	end
end

function BankItems_PopulateVoidStorage(tab)
	if BankItems_Save.voidBags then return end
	tab = tab or 1
	BankItems_VoidFrame.currentTab = tab
	local slotOffset = (tab - 1) * 80
	if bankPlayer.Bag104 then
		-- Void Storage has been seen before
		BankItems_VoidFrame.title:SetText(VOID_STORAGE.." - "..gsub(bankPlayerName, "|", L[" of "]))
		BankItems_VoidFrame.infotext:Hide()
		BankItems_VoidFrame.StorageFrame:Show() --show frame containing all the void buttons
		
		for i = 1, 80 do
			if bankPlayer.Bag104[i+slotOffset] then
				-- Item exists
				local quality = select(3, GetItemInfo(bankPlayer.Bag104[i+slotOffset].link))
				if quality and (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					VoidButtonAr[i].IconBorder:Show()
					VoidButtonAr[i].IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
				else
					VoidButtonAr[i].IconBorder:Hide()
				end
				VoidButtonAr[i].icon:SetTexture(GetItemIcon(bankPlayer.Bag104[i+slotOffset].link))
				if bankPlayer.Bag104[i+slotOffset].count then
					VoidButtonAr[i].Count:Show()
					VoidButtonAr[i].Count:SetText(bankPlayer.Bag104[i+slotOffset].count)
				else
					VoidButtonAr[i].Count:Hide()
				end
			else
				-- Item doesn't exist
				VoidButtonAr[i].icon:SetTexture()
				VoidButtonAr[i].IconBorder:Hide()
				VoidButtonAr[i].Count:Hide()
			end
			--VoidButtonAr[i]:Show()
		end
		BankItems_FilterBags()
	else
		-- Void Storage hasn't been seen before
		BankItems_VoidFrame.title:SetText(VOID_STORAGE.." - "..gsub(bankPlayerName, "|", L[" of "]).." |cFFFFFFFF"..L["(Not seen before)"])
		BankItems_VoidFrame.infotext:SetFormattedText(L["%s data not found. Please visit the Void Storage on this character."]:format(VOID_STORAGE))
		BankItems_VoidFrame.infotext:Show()
		BankItems_VoidFrame.StorageFrame:Hide() --hide frame containing all the void buttons
	end
	for i = 1, 2 do
		if i == tab then
			VoidTabFrameAr[i].button:SetChecked(1)
		else
			VoidTabFrameAr[i].button:SetChecked(nil)
		end
	end
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Minimap Button

BankItems_MinimapButton = CreateFrame("Button", "BankItems_MinimapButton", Minimap)
BankItems_MinimapButton:EnableMouse(true)
BankItems_MinimapButton:SetMovable(false)
BankItems_MinimapButton:SetFrameStrata("LOW")
BankItems_MinimapButton:SetWidth(33)
BankItems_MinimapButton:SetHeight(33)
BankItems_MinimapButton:SetPoint("TOPLEFT", Minimap, "RIGHT", 2, 0)
BankItems_MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

BankItems_MinimapButton:CreateTexture("BankItems_MinimapButtonIcon", "BORDER")
BankItems_MinimapButtonIcon:SetWidth(20)
BankItems_MinimapButtonIcon:SetHeight(20)
BankItems_MinimapButtonIcon:SetPoint("CENTER", -2, 1)
BankItems_MinimapButtonIcon:SetTexture("Interface\\Icons\\INV_Misc_Bag_10_Blue")

BankItems_MinimapButton:CreateTexture("BankItems_MinimapButtonBorder", "OVERLAY")
BankItems_MinimapButtonBorder:SetWidth(52)
BankItems_MinimapButtonBorder:SetHeight(52)
BankItems_MinimapButtonBorder:SetPoint("TOPLEFT")
BankItems_MinimapButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

function BankItems_MinimapButton_Init()
	-- Initialise defaults if not present
	if BankItems_Save.ButtonShown == false then
		BankItems_MinimapButton:Hide()
		BankItems_Save.ButtonShown = false
	else
		BankItems_MinimapButton:Show()
		BankItems_Save.ButtonShown = true
	end
	BankItems_Save.ButtonRadius = BankItems_Save.ButtonRadius or 78
	BankItems_Save.ButtonPosition = BankItems_Save.ButtonPosition or 345
	BankItems_MinimapButton_UpdatePosition()
end

function BankItems_MinimapButton_UpdatePosition()
	BankItems_MinimapButton:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		54 - (BankItems_Save.ButtonRadius * cos(BankItems_Save.ButtonPosition)),
		(BankItems_Save.ButtonRadius * sin(BankItems_Save.ButtonPosition)) - 55
	)
end

-- Thanks to Yatlas for this code
function BankItems_MinimapButton_BeingDragged()
	-- Thanks to Gello for this code
	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	local v = math.deg(math.atan2(ypos, xpos))
	if v < 0 then
		v = v + 360
	end
	BankItems_Save.ButtonPosition = v
	BankItems_MinimapButton_UpdatePosition()

	if BankItems_OptionsFrame:IsVisible() then
		BankItems_ButtonRadiusSlider:SetValue(BankItems_Save.ButtonRadius)
		BankItems_ButtonPosSlider:SetValue(BankItems_Save.ButtonPosition)
	end
end

BankItems_MinimapButton:RegisterEvent("VARIABLES_LOADED")
BankItems_MinimapButton:RegisterForDrag("RightButton")
BankItems_MinimapButton:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", BankItems_MinimapButton_BeingDragged)
end)
BankItems_MinimapButton:SetScript("OnDragStop", function(self)
	self:SetScript("OnUpdate", nil)
end)
BankItems_MinimapButton:SetScript("OnClick", function(self)
	BankItems_SlashHandler()
end)
BankItems_MinimapButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(BANKITEMS_VERSIONTEXT)
	GameTooltip:AddLine(L["Left-click to open BankItems."])
	GameTooltip:AddLine(L["Right-click and drag to move this button."])
	GameTooltip:Show()
end)
BankItems_MinimapButton:SetScript("OnLeave", BankItems_Button_OnLeave)
BankItems_MinimapButton:SetScript("OnEvent", BankItems_MinimapButton_Init)


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Options Frame

do
	local temp

	-- Create the BankItems Options frame
	BankItems_OptionsFrame = CreateFrame("Frame", "BankItems_OptionsFrame", UIParent)
	BankItems_OptionsFrame:Hide()
	BankItems_OptionsFrame:SetWidth(300)
	BankItems_OptionsFrame:SetHeight(410)
	BankItems_OptionsFrame:SetFrameStrata("DIALOG")

	-- Title text
	temp = BankItems_OptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	temp:SetPoint("TOPLEFT", 16, -16)
	temp:SetText(L["BankItems Options"])

	-- Lock Window checkbox
	BankItems_OptionsFrame_LockWindow = CreateFrame("CheckButton", "BankItems_OptionsFrame_LockWindow", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_LockWindow:SetPoint("TOPLEFT", 16, -35)
	BankItems_OptionsFrame_LockWindow:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_LockWindowText:SetText(L["Lock main window from being moved"])
	BankItems_OptionsFrame_LockWindow:SetScript("OnClick", function(self)
		if BankItems_Save.LockWindow then
			BankItems_Save.LockWindow = false
			BankItems_Frame:RegisterForDrag("LeftButton")
			BankItems_GBFrame:RegisterForDrag("LeftButton")
			BankItems_RBFrame:RegisterForDrag("LeftButton")
			BankItems_VoidFrame:RegisterForDrag("LeftButton")
		else
			BankItems_Save.LockWindow = true
			BankItems_Frame:RegisterForDrag()
			BankItems_GBFrame:RegisterForDrag()
			BankItems_RBFrame:RegisterForDrag()
			BankItems_VoidFrame:RegisterForDrag()
		end
		self:SetChecked(BankItems_Save.LockWindow)
	end)

	-- Minimap Button checkbox
	BankItems_OptionsFrame_MinimapButton = CreateFrame("CheckButton", "BankItems_OptionsFrame_MinimapButton", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_MinimapButton:SetPoint("TOPLEFT", 16, -57)
	BankItems_OptionsFrame_MinimapButton:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_MinimapButtonText:SetText(L["Show the minimap button"])
	BankItems_OptionsFrame_MinimapButton:SetScript("OnClick", function(self)
		if BankItems_Save.ButtonShown then
			BankItems_Save.ButtonShown = false
			BankItems_MinimapButton:Hide()
		else
			BankItems_Save.ButtonShown = true
			BankItems_MinimapButton:Show()
		end
		self:SetChecked(BankItems_Save.ButtonShown)
	end)

	-- Window Style checkbox
	BankItems_OptionsFrame_WindowStyle = CreateFrame("CheckButton", "BankItems_OptionsFrame_WindowStyle", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_WindowStyle:SetPoint("TOPLEFT", 16, -79)
	BankItems_OptionsFrame_WindowStyle:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_WindowStyleText:SetText(L["Open BankItems with Blizzard windows"])
	BankItems_OptionsFrame_WindowStyle:SetScript("OnClick", function(self)
		HideUIPanel(BankItems_Frame)
		if BankItems_Save.WindowStyle == 2 then
			BankItems_Save.WindowStyle = 1
			self:SetChecked(false)
			BankItems_Frame:SetAttribute("UIPanelLayout-enabled", nil)
		else
			BankItems_Save.WindowStyle = 2
			self:SetChecked(true)
			BankItems_Frame:SetAttribute("UIPanelLayout-enabled", true)
			BankItems_ScaleSlider:SetValue(100)
			BankItems_Chat(L["Note - Blizzard frames doesn't like it if your scale isn't 100% when using this option."])
		end
	end)

	-- Bag Parent checkbox
	BankItems_OptionsFrame_BagParent = CreateFrame("CheckButton", "BankItems_OptionsFrame_BagParent", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_BagParent:SetPoint("TOPLEFT", 16, -101)
	BankItems_OptionsFrame_BagParent:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_BagParentText:SetText(L["Open BankItems bags with Blizzard bags"])
	BankItems_OptionsFrame_BagParent:SetScript("OnClick", function(self)
		BankItems_Frame_OnHide()
		if BankItems_Save.BagParent == 1 then
			BankItems_Save.BagParent = 2
			self:SetChecked(true)
			updateContainerFrameAnchors = BankItems_updateContainerFrameAnchors
			updateContainerFrameAnchors()
		elseif BankItems_Save.BagParent == 2 then
			BankItems_Save.BagParent = 1
			self:SetChecked(false)
			for _, i in ipairs(BAGNUMBERS) do
				if BagContainerAr[i] then
					BagContainerAr[i]:SetScale(BankItems_Save.Scale / 100)
				end
			end
			updateContainerFrameAnchors = BANKITEMS_UCFA
			BankItemsUpdateCFrameAnchors()
		end
	end)

	-- Option to restore showing Void Storage as a bag
	BankItems_OptionsFrame_VoidBag = CreateFrame("CheckButton", "BankItems_OptionsFrame_VoidBag", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_VoidBag:SetPoint("TOPLEFT", 16, -123)
	BankItems_OptionsFrame_VoidBag:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_VoidBagText:SetText(L["Show void storage contents in a bag"])
	BankItems_OptionsFrame_VoidBag:SetScript("OnClick", function(self)
		if BankItems_Save.voidBags then
			BankItems_Save.voidBags = false
			if BagContainerAr[104]:IsVisible() then --if bag is visible close it since we want to show the new frame style now
				BagContainerAr[104]:Hide()
			end
		else
			BankItems_Save.voidBags = true
			if BankItems_VoidFrame:IsVisible()  then --if new frame is visible close it since we want to show the bag now
				HideUIPanel(BankItems_VoidFrame)
			end
		end
		self:SetChecked(BankItems_Save.voidBags)
	end)

	-- Option to restore showing the Reagent Bank as a bag
	BankItems_OptionsFrame_ReagentBag = CreateFrame("CheckButton", "BankItems_OptionsFrame_ReagentBag", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_ReagentBag:SetPoint("TOPLEFT", 16, -145)
	BankItems_OptionsFrame_ReagentBag:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_ReagentBagText:SetText(L["Show reagent bank contents in a bag"])
	BankItems_OptionsFrame_ReagentBag:SetScript("OnClick", function(self)
		if BankItems_Save.reagentBags then
			BankItems_Save.reagentBags = false
			if BagContainerAr[105]:IsVisible() then --if bag is visible close it since we want to show the new frame style now
				BagContainerAr[105]:Hide()
			end
		else
			BankItems_Save.reagentBags = true
			if BankItems_RBFrame:IsVisible()  then --if new frame is visible close it since we want to show the bag now
				HideUIPanel(BankItems_RBFrame)
			end
		end
		self:SetChecked(BankItems_Save.reagentBags)
	end)	

	-- Add Tooltip Info checkbox
	BankItems_OptionsFrame_TooltipInfo = CreateFrame("CheckButton", "BankItems_OptionsFrame_TooltipInfo", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_TooltipInfo:SetPoint("TOPLEFT", 16, -167)
	BankItems_OptionsFrame_TooltipInfo:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_TooltipInfoText:SetText(L["Show extra item tooltip information"])
	BankItems_OptionsFrame_TooltipInfo:SetScript("OnClick", function(self)
		if BankItems_Save.TooltipInfo then
			BankItems_Save.TooltipInfo = false
			delTable(BankItems_Cache)
			delTable(BankItems_SelfCache)
			delTable(BankItems_GuildCache)
			BankItems_Cache = newTable()
			BankItems_SelfCache = newTable()
			BankItems_GuildCache = newTable()
			UIDropDownMenu_DisableDropDown(BankItems_GTTDropDown)
			BlizzardOptionsPanel_CheckButton_Disable(BankItems_OptionsFrame_TTSoulbound)
		else
			BankItems_Save.TooltipInfo = true
			BankItems_Generate_ItemCache()
			BankItems_Generate_SelfItemCache()
			BankItems_Generate_GuildItemCache()
			UIDropDownMenu_EnableDropDown(BankItems_GTTDropDown)
			BlizzardOptionsPanel_CheckButton_Enable(BankItems_OptionsFrame_TTSoulbound)
			BankItems_HookTooltips()
		end
		self:SetChecked(BankItems_Save.TooltipInfo)
	end)

	-- Ignore unstackable soulbound items --Moved since it looked like a sub-option for the guild dropdown in its previous position
	BankItems_OptionsFrame_TTSoulbound = CreateFrame("CheckButton", "BankItems_OptionsFrame_TTSoulbound", BankItems_OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
	BankItems_OptionsFrame_TTSoulbound:SetPoint("TOPLEFT", 16, -189)
	BankItems_OptionsFrame_TTSoulbound:SetHitRectInsets(0, -300, 0, 0)
	BankItems_OptionsFrame_TTSoulboundText:SetText(L["Ignore unstackable soulbound items"])
	BankItems_OptionsFrame_TTSoulbound:SetScript("OnClick", function(self)
		BankItems_Save.TTSoulbound = not BankItems_Save.TTSoulbound
		delTable(BankItems_TooltipCache)
		BankItems_TooltipCache = newTable()
	end)
	
	-- Guildtooltip dropdown --align with other dropdown
	BankItems_GTTDropDown = CreateFrame("Frame", "BankItems_GTTDropDown", BankItems_OptionsFrame, "UIDropDownMenuTemplate")
	BankItems_GTTDropDown:SetPoint("TOPLEFT", 5, -228)
	BankItems_GTTDropDown:SetHitRectInsets(16, 16, 0, 0)
	UIDropDownMenu_SetWidth(BankItems_GTTDropDown, 320)
	UIDropDownMenu_EnableDropDown(BankItems_GTTDropDown)
	BankItems_GTTDropDown:CreateFontString("BankItems_GTTDropDownLabel", "BACKGROUND", "GameFontNormalSmall")
	BankItems_GTTDropDownLabel:SetPoint("BOTTOMLEFT", BankItems_GTTDropDown, "TOPLEFT", 21, 1)
	BankItems_GTTDropDownLabel:SetText(L["Include the following guild banks:"])

	-- Behavior dropdown
	BankItems_BehaviorDropDown = CreateFrame("Frame", "BankItems_BehaviorDropDown", BankItems_OptionsFrame, "UIDropDownMenuTemplate")
	BankItems_BehaviorDropDown:SetPoint("TOPLEFT", 5, -268)
	BankItems_BehaviorDropDown:SetHitRectInsets(16, 16, 0, 0)
	UIDropDownMenu_SetWidth(BankItems_BehaviorDropDown, 320)
	UIDropDownMenu_EnableDropDown(BankItems_BehaviorDropDown)
	BankItems_BehaviorDropDown:CreateFontString("BankItems_BehaviorDropDownLabel", "BACKGROUND", "GameFontNormalSmall")
	BankItems_BehaviorDropDownLabel:SetPoint("BOTTOMLEFT", BankItems_BehaviorDropDown, "TOPLEFT", 21, 1)
	BankItems_BehaviorDropDownLabel:SetText(L[ [[On the command "/bi":]] ])

	-- Minimap Button Radius slider
	BankItems_ButtonRadiusSlider = CreateFrame("Slider", "BankItems_ButtonRadiusSlider", BankItems_OptionsFrame, "OptionsSliderTemplate")
	BankItems_ButtonRadiusSlider:SetWidth(335)
	BankItems_ButtonRadiusSlider:SetHeight(16)
	BankItems_ButtonRadiusSlider:SetPoint("TOPLEFT", 25, -312)
	BankItems_ButtonRadiusSliderLow:SetText("0")
	BankItems_ButtonRadiusSliderHigh:SetText("200")
	BankItems_ButtonRadiusSlider:SetMinMaxValues(0,200)
	BankItems_ButtonRadiusSlider:SetValueStep(1)
	BankItems_ButtonRadiusSlider:SetScript("OnValueChanged", function(self, value)
		BankItems_ButtonRadiusSliderText:SetFormattedText(L["Minimap Button Radius %d"], value)
		BankItems_Save.ButtonRadius = value
		BankItems_MinimapButton_UpdatePosition()
	end)

	-- Minimap Button Position slider
	BankItems_ButtonPosSlider = CreateFrame("Slider", "BankItems_ButtonPosSlider", BankItems_OptionsFrame, "OptionsSliderTemplate")
	BankItems_ButtonPosSlider:SetWidth(335)
	BankItems_ButtonPosSlider:SetHeight(16)
	BankItems_ButtonPosSlider:SetPoint("TOPLEFT", 25, -345)
	BankItems_ButtonPosSliderLow:SetText("0")
	BankItems_ButtonPosSliderHigh:SetText("360")
	BankItems_ButtonPosSlider:SetMinMaxValues(0, 360)
	BankItems_ButtonPosSlider:SetValueStep(1)
	BankItems_ButtonPosSlider:SetScript("OnValueChanged", function(self, value)
		BankItems_ButtonPosSliderText:SetFormattedText(L["Minimap Button Position %d"], value)
		BankItems_Save.ButtonPosition = value
		BankItems_MinimapButton_UpdatePosition()
	end)

	-- Transparency slider
	BankItems_TransparencySlider = CreateFrame("Slider", "BankItems_TransparencySlider", BankItems_OptionsFrame, "OptionsSliderTemplate")
	BankItems_TransparencySlider:SetWidth(335)
	BankItems_TransparencySlider:SetHeight(16)
	BankItems_TransparencySlider:SetPoint("TOPLEFT", 25, -378)
	BankItems_TransparencySliderLow:SetText("25%")
	BankItems_TransparencySliderHigh:SetText("100%")
	BankItems_TransparencySlider:SetMinMaxValues(25, 100)
	BankItems_TransparencySlider:SetValueStep(1)
	BankItems_TransparencySlider:SetScript("OnValueChanged", function(self, value)
		BankItems_TransparencySliderText:SetFormattedText(L["Transparency %d%%"], value)
		BankItems_Save.Transparency = value
		BankItems_Frame:SetAlpha(value / 100)
		BankItems_GBFrame:SetAlpha(value / 100)
		BankItems_RBFrame:SetAlpha(value / 100)
		BankItems_VoidFrame:SetAlpha(value / 100)
	end)

	-- Scale slider
	BankItems_ScaleSlider = CreateFrame("Slider", "BankItems_ScaleSlider", BankItems_OptionsFrame, "OptionsSliderTemplate")
	BankItems_ScaleSlider:SetWidth(335)
	BankItems_ScaleSlider:SetHeight(16)
	BankItems_ScaleSlider:SetPoint("TOPLEFT", 25, -411)
	BankItems_ScaleSliderLow:SetText("50%")
	BankItems_ScaleSliderHigh:SetText("100%")
	BankItems_ScaleSlider:SetMinMaxValues(50, 100)
	BankItems_ScaleSlider:SetValueStep(1)
	BankItems_ScaleSlider:SetScript("OnValueChanged", function(self, value)
		BankItems_ScaleSliderText:SetFormattedText(L["Scaling %d%%"], value)
		BankItems_Save.Scale = value
		BankItems_Frame:SetScale(value / 100)
		BankItems_GBFrame:SetScale(value / 100)
		BankItems_RBFrame:SetScale(value / 100)
		BankItems_VoidFrame:SetScale(value / 100)
		if BankItems_Save.BagParent == 1 then
			for _, i in ipairs(BAGNUMBERS) do
				if BagContainerAr[i] then
					BagContainerAr[i]:SetScale(BankItems_Save.Scale / 100)
					BagContainerAr[i]:SetAlpha(BankItems_Save.Transparency / 100)
				end
			end
			BankItemsUpdateCFrameAnchors()
		elseif BankItems_Save.BagParent == 2 then
			for _, i in ipairs(BAGNUMBERS) do
				if BagContainerAr[i] then
					BagContainerAr[i]:SetAlpha(1)
				end
			end
			updateContainerFrameAnchors()
		end
	end)

	-- Add to Blizzard Interface Options
	BankItems_OptionsFrame.name = BANKITEMS_VERSIONTEXT
	InterfaceOptions_AddCategory(BankItems_OptionsFrame)
end

function BankItems_Options_Init(self, event)
	-- Initialise defaults if not present
	if BankItems_Save.LockWindow == nil then
		BankItems_Save.LockWindow = true
	end
	BankItems_Save.Scale = BankItems_Save.Scale or 80
	BankItems_Save.Transparency = BankItems_Save.Transparency or 100
	BankItems_Save.BagParent = BankItems_Save.BagParent or 1
	BankItems_Save.WindowStyle = BankItems_Save.WindowStyle or 1
	BankItems_Save.Behavior = BankItems_Save.Behavior or {false, false, false, false, false, false, false, false}
	BankItems_Save.Behavior[5] = BankItems_Save.Behavior[5] or false	-- currency bag
	BankItems_Save.Behavior[6] = BankItems_Save.Behavior[6] or false	-- auction bag
	BankItems_Save.Behavior[7] = BankItems_Save.Behavior[7] or false	-- void storage
	BankItems_Save.Behavior[8] = BankItems_Save.Behavior[8] or false	-- reagent bank
	BankItems_Save.Behavior2 = BankItems_Save.Behavior2 or {true, true, false, true}
	BankItems_Save.Behavior2[5] = BankItems_Save.Behavior2[5] or false	-- Update for guild banks
	if BankItems_Save.ExportPrefix == nil then
		BankItems_Save.ExportPrefix = true
	end
	if BankItems_Save.GroupExportData == nil then
		BankItems_Save.GroupExportData = false
	end
	if BankItems_Save.SearchAllRealms == nil then
		BankItems_Save.SearchAllRealms = false
	end
	if BankItems_Save.TooltipInfo == nil then
		BankItems_Save.TooltipInfo = true
	end
	if BankItems_Save.TTSoulbound == nil then
		BankItems_Save.TTSoulbound = true
	end
	if BankItems_Save.ShowOppositeFaction == nil then
		BankItems_Save.ShowOppositeFaction = false
	end
	if BankItems_Save.ShowAllRealms == nil then
		BankItems_Save.ShowAllRealms = false
	end
	if BankItems_Save.voidBags == nil then
		BankItems_Save.voidBags = false
	end
	if BankItems_Save.reagentBags == nil then
		BankItems_Save.reagentBags = false
	end

	-- Apply saved settings
	if BankItems_Save.LockWindow then
		BankItems_Frame:RegisterForDrag()
		BankItems_GBFrame:RegisterForDrag()
		BankItems_RBFrame:RegisterForDrag()
		BankItems_VoidFrame:RegisterForDrag()
	else
		BankItems_Frame:RegisterForDrag("LeftButton")
		BankItems_GBFrame:RegisterForDrag("LeftButton")
		BankItems_RBFrame:RegisterForDrag("LeftButton")
		BankItems_VoidFrame:RegisterForDrag("LeftButton")
	end
	BankItems_Frame:SetScale(BankItems_Save.Scale / 100)
	BankItems_Frame:SetAlpha(BankItems_Save.Transparency / 100)
	BankItems_GBFrame:SetScale(BankItems_Save.Scale / 100)
	BankItems_GBFrame:SetAlpha(BankItems_Save.Transparency / 100)
	BankItems_RBFrame:SetScale(BankItems_Save.Scale / 100)
	BankItems_RBFrame:SetAlpha(BankItems_Save.Transparency / 100)
	BankItems_VoidFrame:SetScale(BankItems_Save.Scale / 100)
	BankItems_VoidFrame:SetAlpha(BankItems_Save.Transparency / 100)
	if BankItems_Save.BagParent == 1 then
		--for _, i in ipairs(BAGNUMBERS) do
		--	BagContainerAr[i]:SetScale(BankItems_Save.Scale / 100)
		--	BagContainerAr[i]:SetAlpha(BankItems_Save.Transparency / 100)
		--end
	elseif BankItems_Save.BagParent == 2 then
		updateContainerFrameAnchors = BankItems_updateContainerFrameAnchors
	end
	BankItems_Frame:SetAttribute("UIPanelLayout-defined", true)
	for name, value in pairs(BANKITEMS_UIPANELWINDOWS_TABLE) do
		BankItems_Frame:SetAttribute("UIPanelLayout-"..name, value)
	end
	if BankItems_Save.WindowStyle == 1 then
		BankItems_Frame:SetAttribute("UIPanelLayout-enabled", nil)
	elseif BankItems_Save.WindowStyle == 2 then
		BankItems_Frame:SetAttribute("UIPanelLayout-enabled", true)
	end
	BankItems_BehaviorDropDown.initialize = BankItems_BehaviorDropDown_Initialize
	BankItems_BehaviorDropDownText:SetText(L["Open BankItems and..."])
	BankItems_GTTDropDown.initialize = BankItems_GuildTTDropdown_Initialize
	if BankItems_Save.TooltipInfo then
		BankItems_HookTooltips()
	else
		UIDropDownMenu_DisableDropDown(BankItems_GTTDropDown)
		BlizzardOptionsPanel_CheckButton_Disable(BankItems_OptionsFrame_TTSoulbound)
	end

	self:UnregisterEvent("VARIABLES_LOADED")
	self:SetScript("OnEvent", nil)
	BankItems_Options_Init = nil
end

function BankItems_BehaviorDropDown_Initialize()
	for i = 1, #BANKITEMS_BEHAVIORLIST do
		info.checked		= BankItems_Save.Behavior[i]
		info.text		= BANKITEMS_BEHAVIORLIST[i]
		info.func		= BankItems_BehaviorDropDown_OnClick
		info.arg1		= i
		info.arg2		= nil
		info.keepShownOnClick	= 1
		info.isNotRadio = 1
		UIDropDownMenu_AddButton(info)
	end
end

function BankItems_BehaviorDropDown_OnClick(button, selected)
	BankItems_Save.Behavior[selected] = not BankItems_Save.Behavior[selected]
end

function BankItems_GuildTTDropdown_Initialize()
	for _, key in ipairs(sortedGuildKeys) do
		local f = BankItems_SaveGuild[key].faction
		if f == "Alliance" then f = FACTION_ALLIANCE
		elseif f == "Horde" then f = FACTION_HORDE
		else f = UNKNOWN
		end
		info.text = gsub(key, "(.*)|", "<%1>"..L[" of "]).." ("..f..")"
		info.arg1 = key
		info.arg2 = gsub(key, "(.*)|", "<%1>"..L[" of "])
		info.func = BankItems_GuildTTDropdown_OnClick
		info.checked = BankItems_SaveGuild[key].track
		info.keepShownOnClick = 1
		info.isNotRadio = 1
		UIDropDownMenu_AddButton(info)
	end
end

function BankItems_GuildTTDropdown_OnClick(button, guildName, text)
	BankItems_SaveGuild[guildName].track = not BankItems_SaveGuild[guildName].track
	BankItems_Generate_GuildItemCache()
	local n = 0
	for _, key in ipairs(sortedGuildKeys) do
		if BankItems_SaveGuild[key].track then n = n + 1 end
	end
	BankItems_GTTDropDownText:SetFormattedText(L["%d guild bank(s) selected"], n)
end

function BankItems_Options_OnShow()
	BankItems_OptionsFrame_LockWindow:SetChecked(BankItems_Save.LockWindow)
	BankItems_OptionsFrame_MinimapButton:SetChecked(BankItems_Save.ButtonShown)
	BankItems_OptionsFrame_WindowStyle:SetChecked(BankItems_Save.WindowStyle == 2)
	BankItems_OptionsFrame_BagParent:SetChecked(BankItems_Save.BagParent == 2)
	BankItems_OptionsFrame_VoidBag:SetChecked(BankItems_Save.voidBags)
	BankItems_OptionsFrame_ReagentBag:SetChecked(BankItems_Save.reagentBags)
	BankItems_OptionsFrame_TooltipInfo:SetChecked(BankItems_Save.TooltipInfo)
	BankItems_ButtonRadiusSlider:SetValue(BankItems_Save.ButtonRadius)
	BankItems_ButtonPosSlider:SetValue(BankItems_Save.ButtonPosition)
	BankItems_TransparencySlider:SetValue(BankItems_Save.Transparency)
	BankItems_ScaleSlider:SetValue(BankItems_Save.Scale)
	local n = 0
	for _, key in ipairs(sortedGuildKeys) do
		if BankItems_SaveGuild[key].track then n = n + 1 end
	end
	BankItems_GTTDropDownText:SetFormattedText(L["%d guild bank(s) selected"], n)
	BankItems_OptionsFrame_TTSoulbound:SetChecked(BankItems_Save.TTSoulbound)
end

BankItems_OptionsFrame:RegisterEvent("VARIABLES_LOADED")
BankItems_OptionsFrame:SetScript("OnEvent", BankItems_Options_Init)
BankItems_OptionsFrame:SetScript("OnShow", BankItems_Options_OnShow)


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Export Frame

do
	local temp
	local BANKITEMS_EXPORT_BACKDROP = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
	 	insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}

	-- Create the BankItems Export frame
	BankItems_ExportFrame = CreateFrame("Frame", "BankItems_ExportFrame", UIParent, "DialogBoxFrame")
	BankItems_ExportFrame:Hide()
	BankItems_ExportFrame:SetWidth(500)
	BankItems_ExportFrame:SetHeight(400)
	BankItems_ExportFrame:SetPoint("CENTER")
	BankItems_ExportFrame:EnableMouse(true)
	BankItems_ExportFrame:SetToplevel(true)
	BankItems_ExportFrame:SetMovable(true)
	BankItems_ExportFrame:SetFrameStrata("DIALOG")
	BankItems_ExportFrame:SetBackdrop(BANKITEMS_EXPORT_BACKDROP)

	-- Title text
	temp = BankItems_ExportFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	temp:SetPoint("TOPLEFT", 5, -5)
	temp:SetText(BANKITEMS_VERSIONTEXT)

	-- Group Data checkbox
	BankItems_ExportFrame_GroupData = CreateFrame("CheckButton", "BankItems_ExportFrame_GroupData", BankItems_ExportFrame, "OptionsCheckButtonTemplate")
	BankItems_ExportFrame_GroupData:SetPoint("BOTTOMLEFT", 5, 5)
	BankItems_ExportFrame_GroupData:SetHitRectInsets(0, -100, 3, 0)
	BankItems_ExportFrame_GroupDataText:SetText(L["Group similar items"])
	BankItems_ExportFrame_GroupData:SetScript("OnClick", function(self)
		if BankItems_Save.GroupExportData then
			BankItems_Save.GroupExportData = false
		else
			BankItems_Save.GroupExportData = true
		end
		self:SetChecked(BankItems_Save.GroupExportData)
		BankItems_ExportFrame_ShowBagPrefix:SetChecked(false)
		BankItems_Save.ExportPrefix = false
		BankItems_ExportFrame_ResetButton:Click()
	end)

	-- Show Bag Prefix checkbox
	BankItems_ExportFrame_ShowBagPrefix = CreateFrame("CheckButton", "BankItems_ExportFrame_ShowBagPrefix", BankItems_ExportFrame, "OptionsCheckButtonTemplate")
	BankItems_ExportFrame_ShowBagPrefix:SetPoint("BOTTOMLEFT", 5, 25)
	BankItems_ExportFrame_ShowBagPrefix:SetHitRectInsets(0, -100, 0, 0)
	BankItems_ExportFrame_ShowBagPrefixText:SetText(L["Show bag prefix"])
	BankItems_ExportFrame_ShowBagPrefix:SetScript("OnClick", function(self)
		if BankItems_Save.ExportPrefix then
			BankItems_Save.ExportPrefix = false
		else
			BankItems_Save.ExportPrefix = true
		end
		self:SetChecked(BankItems_Save.ExportPrefix)
		BankItems_ExportFrame_GroupData:SetChecked(false)
		BankItems_Save.GroupExportData = false
		BankItems_ExportFrame_ResetButton:Click()
	end)

	-- Search Filter dropdown
	BankItems_ExportFrame_SearchDropDown = CreateFrame("Frame", "BankItems_ExportFrame_SearchDropDown", BankItems_ExportFrame, "UIDropDownMenuTemplate")
	BankItems_ExportFrame_SearchDropDown:SetPoint("BOTTOMLEFT", -9, 45)
	BankItems_ExportFrame_SearchDropDown:SetHitRectInsets(16, 16, 0, 0)
	UIDropDownMenu_SetWidth(BankItems_ExportFrame_SearchDropDown, 150)
	UIDropDownMenu_EnableDropDown(BankItems_ExportFrame_SearchDropDown)
	function BankItems_ExportFrame_SearchDropDown_OnClick(button, selected)
		BankItems_Save.Behavior2[selected] = not BankItems_Save.Behavior2[selected]
	end
	BankItems_ExportFrame_SearchDropDown.initialize = function()
		for i = 1, #BANKITEMS_BEHAVIORLIST2 do
			info.checked		= BankItems_Save.Behavior2[i]
			info.text		= BANKITEMS_BEHAVIORLIST2[i]
			info.func		= BankItems_ExportFrame_SearchDropDown_OnClick
			info.arg1		= i
			info.arg2		= nil
			info.keepShownOnClick	= 1
			UIDropDownMenu_AddButton(info)
		end
	end
	BankItems_ExportFrame_SearchDropDownText:SetText(L["Search these bags..."])

	-- Search editbox
	BankItems_ExportFrame_SearchTextbox = CreateFrame("EditBox", "BankItems_ExportFrame_SearchTextbox", BankItems_ExportFrame, "InputBoxTemplate")
	BankItems_ExportFrame_SearchTextbox:SetWidth(167)
	BankItems_ExportFrame_SearchTextbox:SetHeight(16)
	BankItems_ExportFrame_SearchTextbox:SetPoint("BOTTOMRIGHT", -10, 35)
	BankItems_ExportFrame_SearchTextbox:SetMaxLetters(50)
	BankItems_ExportFrame_SearchTextbox:SetNumeric(false)
	BankItems_ExportFrame_SearchTextbox:SetAutoFocus(false)
	BankItems_ExportFrame_SearchTextbox:SetScript("OnEnterPressed", function(self)
		BankItems_ExportFrame_ResetButton:Click()
	end)
	BankItems_ExportFrame_SearchTextbox:SetScript("OnEscapePressed", BankItems_ExportFrame_SearchTextbox.ClearFocus)
	BankItems_ExportFrame_SearchTextbox:SetScript("OnTabPressed", function(self)
		BankItems_ExportFrame_ScrollText:SetFocus()
	end)

	-- Search All Realms checkbox
	BankItems_ExportFrame_SearchAllRealms = CreateFrame("CheckButton", "BankItems_ExportFrame_SearchAllRealms", BankItems_ExportFrame, "OptionsCheckButtonTemplate")
	BankItems_ExportFrame_SearchAllRealms:SetPoint("TOPLEFT", BankItems_ExportFrame_SearchTextbox, "BOTTOMLEFT", -10, 3)
	BankItems_ExportFrame_SearchAllRealms:SetHitRectInsets(0, -60, 0, 0)
	BankItems_ExportFrame_SearchAllRealmsText:SetText(L["All Realms"])
	BankItems_ExportFrame_SearchAllRealms:SetScript("OnClick", function(self)
		if BankItems_Save.SearchAllRealms then
			BankItems_Save.SearchAllRealms = false
		else
			BankItems_Save.SearchAllRealms = true
		end
		self:SetChecked(BankItems_Save.SearchAllRealms)
		BankItems_ExportFrame_ResetButton:Click()
	end)

	-- Reset/Search button
	BankItems_ExportFrame_ResetButton = CreateFrame("Button", "BankItems_ExportFrame_ResetButton", BankItems_ExportFrame, "UIPanelButtonTemplate")
	BankItems_ExportFrame_ResetButton:SetWidth(80)
	BankItems_ExportFrame_ResetButton:SetHeight(24)
	BankItems_ExportFrame_ResetButton:SetPoint("BOTTOMRIGHT", -10, 10)
	BankItems_ExportFrame_ResetButton:SetText(RESET)
	BankItems_ExportFrame_ResetButton:SetScript("OnClick", function(self)
		if BankItems_ExportFrame.mode == "search" then
			BankItems_ExportFrame_SearchTextbox:SetText(strtrim(BankItems_ExportFrame_SearchTextbox:GetText()))
			BankItems_ExportFrame_SearchTextbox:ClearFocus()
			BankItems_Search(BankItems_ExportFrame_SearchTextbox:GetText())
		elseif BankItems_ExportFrame.mode == "export" then
			BankItems_GenerateExportText()
		elseif BankItems_ExportFrame.mode == "exportguild" then
			BankItems_GenerateGuildExportText()
		end
	end)

	-- Main scrollframe to display results
	BankItems_ExportFrame_Scroll = CreateFrame("ScrollFrame", "BankItems_ExportFrame_Scroll", BankItems_ExportFrame, "UIPanelScrollFrameTemplate")
	BankItems_ExportFrame_Scroll:SetToplevel(true)
	BankItems_ExportFrame_Scroll:SetWidth(455)
	BankItems_ExportFrame_Scroll:SetHeight(300)
	BankItems_ExportFrame_Scroll:SetPoint("TOP", -10, -20)
		BankItems_ExportFrame_ScrollText = CreateFrame("EditBox", "BankItems_ExportFrame_ScrollText", BankItems_ExportFrame)
		BankItems_ExportFrame_ScrollText:SetWidth(450)
		BankItems_ExportFrame_ScrollText:SetHeight(294)
		BankItems_ExportFrame_ScrollText:SetMaxLetters(99999)
		BankItems_ExportFrame_ScrollText:SetNumeric(false)
		BankItems_ExportFrame_ScrollText:SetAutoFocus(false)
		BankItems_ExportFrame_ScrollText:SetMultiLine(true)
		BankItems_ExportFrame_ScrollText:SetFontObject(ChatFontNormal)
		BankItems_ExportFrame_ScrollText:SetScript("OnTextChanged", function(self) ScrollingEdit_OnTextChanged(self, self:GetParent()) end)
		BankItems_ExportFrame_ScrollText:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
		BankItems_ExportFrame_ScrollText:SetScript("OnUpdate", function(self, elapsed) ScrollingEdit_OnUpdate(self, elapsed, self:GetParent()) end)
		BankItems_ExportFrame_ScrollText:SetScript("OnEscapePressed", BankItems_ExportFrame_ScrollText.ClearFocus)
		BankItems_ExportFrame_ScrollText:SetScript("OnTabPressed", function(self)
			if BankItems_ExportFrame_SearchTextbox:IsVisible() then
				BankItems_ExportFrame_SearchTextbox:SetFocus()
			end
		end)
	BankItems_ExportFrame_Scroll:SetScrollChild(BankItems_ExportFrame_ScrollText)
end