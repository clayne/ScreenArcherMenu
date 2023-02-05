﻿package {
	import flash.display.DisplayObject;
	import flashx.textLayout.formats.Float;
	import flash.utils.Timer;

    public class Data {
		public static var sam:Object;
		public static var f4se:Object;
		public static var stage:DisplayObject;
		
		public static var menuName:String = "";
		public static var menuOptions:Array = [];
		public static var menuValues:Array = [];
		public static var menuSize:int = 0;
		
		public static var menuFolder:Array = [];
		public static var folderStack:Array = [];
		
		public static var entryData:Object = null;
		public static var folderData:Object = null;
		public static var holdData:Object = null;
		
		public static var menuData:Object = {};
		public static var menuType:int = 0;
		public static var error:String = "";
		public static var locals:Object = {};

		public static var cursorStored:Boolean = false;
		public static var cursorPosX:int = -1;
		public static var cursorPosY:int = -1;

		public static var selectedText:SliderListEntry = null;
		
		public static var latentWaiting:Boolean = false;
		public static var latentMenuData:Object;
		public static var latentMenuName:String;
		public static var latentAction:int;

		public static var latentCallbacks:Vector.<LatentCallback> = new Vector.<LatentCallback>(4);
		public static var latentGet:LatentCallback;
		public static var latentNotification:LatentCallback;
		public static var latentTitle:LatentCallback;
		public static var latentSet:LatentCallback;
		
		public static const LATENT_GET = 0;
		public static const LATENT_NOTIF = 1;
		public static const LATENT_TITLE = 2;
		public static const LATENT_SET = 3;
		public static const LATENT_MAX = 4;
		public static const LATENT_PUSH = 5;
		public static const LATENT_POP = 6;
		public static const LATENT_REFRESH = 7;
		public static const LATENT_RELOAD = 8;
	
		public static const EMPTY:String = "";
		public static const ERROR:String = "Error";
		
		//The data constants need to be identical to the sam plugin enums
		public static const NONE:int = 0;
		
		public static const RESULT_SUCCESS:int = 1;
		public static const RESULT_ERROR:int = 2;
		public static const RESULT_WAITING:int = 3;
		public static const RESULT_MENU:int = 4;
		public static const RESULT_VALUES:int = 5;
		public static const RESULT_ITEMS:int = 6;
		public static const RESULT_NAMES:int = 7;
		public static const RESULT_STRING:int = 8;
		public static const RESULT_FOLDER:int = 9;
		public static const RESULT_FOLDERCHECKBOX:int = 10;
		public static const RESULT_NOTIFICATION:int = 11;
		public static const RESULT_TITLE:int = 12;
		
		public static const MENU_MAIN:int = 1;
		public static const MENU_MIXED:int = 2;
		public static const MENU_LIST:int = 3;
		public static const MENU_CHECKBOX:int = 4;
		public static const MENU_SLIDER:int = 5;
		public static const MENU_FOLDER:int = 6;
		public static const MENU_FOLDERCHECKBOX:int = 7;
		public static const MENU_ADJUSTMENT:int = 8;
		
		public static const FUNC_SAM:int = 1;
		public static const FUNC_LOCAL:int = 2;
		public static const FUNC_FORM:int = 3;
		public static const FUNC_GLOBAL:int = 4;
		public static const FUNC_ENTRY:int = 5;
		public static const FUNC_MENU:int = 6;
		public static const FUNC_FOLDER:int = 7;
		
		public static const FUNC_DEBUG:int = 0xDEADBEEF;
		
		public static const HOTKEY_FUNC:int = 1;
		public static const HOTKEY_HOLD:int = 2;
		public static const HOTKEY_TOGGLE:int = 3;
		
		public static const BUTTON_SAVE = 1;
		public static const BUTTON_LOAD = 2;
		public static const BUTTON_RESET = 3;
		public static const BUTTON_EXTRA = 4;
		
		public static const ITEM_LIST:int = 1;
		public static const ITEM_SLIDER:int = 2;
		public static const ITEM_CHECKBOX:int = 3;
		public static const ITEM_TOUCH:int = 4;
		public static const ITEM_FOLDER:int = 5;
		public static const ITEM_ADJUSTMENT:int = 6;
		
		public static const VALUE_NONE:int = 1
		public static const VALUE_INT:int = 2;
		public static const VALUE_FLOAT:int = 3;
		
		public static const ARGS_VAR:int = 1;
		public static const ARGS_INDEX:int = 2;
		public static const ARGS_VALUE:int = 3;
		
		public static const CHECKBOX_CHECK = 1;
		public static const CHECKBOX_SETTINGS = 2;
		public static const CHECKBOX_RECYCLE = 3;
		public static const CHECKBOX_TOUCH = 4;
		public static const CHECKBOX_FOLDER = 5;
		public static const CHECKBOX_DOWN = 6;
		public static const CHECKBOX_UP = 7;
		
		public static const PATH_FILE = 1;
		public static const PATH_RELATIVE = 2;
		public static const PATH_FULL = 3;
		
		public static const SORT_ALPHANUMERIC = 1;
		public static const SORT_NATURAL = 2;
		
		public static var defaultSliderData:Object = {
			type: 2,
			min: 0,
			max: 100,
			step: 1,
			stepKey: 1
		};
		
		public static var defaultTouchData:Object = {
			type: 3,
			fixed: 2,
			step: 2.0
		};
		
		public static var resultSuccess:GFxResult = new GFxResult(RESULT_SUCCESS, null);
		public static var resultWaiting:GFxResult = new GFxResult(RESULT_WAITING, null);
		public static var resultError:GFxResult = new GFxResult(RESULT_ERROR, ERROR);
		
		public static var popFailMenu:GFxResult = new GFxResult(RESULT_MENU, {
			type: MENU_LIST,
			names: []
		});
		
		public static var popFailGet:GFxResult = new GFxResult(RESULT_VALUES, []);
		public static var popFailFolder:GFxResult = new GFxResult(RESULT_FOLDER, []);
		
		public static function getMenu(name:String, pop:Boolean = false):GFxResult
		{
			try {
				var result:GFxResult = sam.GetMenu(name);
				
				//If pop fails, return a dummy menu instead to prevent locks
				if (result && result.type == RESULT_MENU)
					return result;
			}
			catch(e:Error) {}
			
			if (Util.debug) {
				var menu:Object = getDebugMenu(name);
				if (menu)
					return new GFxResult(RESULT_MENU, menu);
			}
			
			return new GFxResult(RESULT_ERROR, "$SAM_MenuMissingError");
		}
		
		public static function updateMenu(name:String, data:Object, result:GFxResult)
		{
			menuName = name;
			menuData = data;
			menuType = data.type;
			
			var i:int;

			//load base menu data first
			switch(menuType) {
				case MENU_MAIN:
					menuSize = data.values.length;
					menuOptions = data.names;
					menuValues = data.values;
					break;
				case MENU_MIXED:
					setMenuSize(data.items.length);
					var items:Object = data.items;
					for (i = 0; i < menuSize; i++) {
						if (items[i].name)
							menuOptions[i] = items[i].name;
						else
							menuOptions[i] = EMPTY;
						menuValues[i] = null;
					}
					break;
				case MENU_LIST:
					if (data.list) {
						setMenuSize(data.list.length);
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = data.list[i].name;
							menuValues[i] = data.list[i].name;
						}
					} else if (data.names) {
						setMenuSize(data.names.length);
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = data.names[i];
							menuValues[i] = data.names[i];
						}
					} else {
						//length specified by get function
						if (result.type == RESULT_ITEMS) {
							setMenuSize(result.result.names.length);
						} else {
							setMenuSize(result.result.length);
						}
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = EMPTY;
							menuValues[i] = EMPTY;
						}
					}
					break;
				case MENU_CHECKBOX:
					if (data.names) {
						setMenuSize(data.names.length);
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = data.names[i];
							menuValues[i] = false;
						}
					} else {
						//length specified by get function
						if (result.type == RESULT_ITEMS) {
							setMenuSize(result.result.names.length);
						} else {
							setMenuSize(result.result.length);
						}
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = EMPTY;
							menuValues[i] = false;
						}
					}
					break;
				case MENU_SLIDER:
					var sliderValue = (data.slider.type == VALUE_FLOAT ? 0.0 : 0);
					if (data.names) {
						setMenuSize(data.names.length);
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = data.names[i];
							menuValues[i] = sliderValue;
						}
					} else {
						//length specified by get function
						if (result.type == RESULT_ITEMS) {
							setMenuSize(result.result.names.length);
						} else {
							setMenuSize(result.result.length);
						}
						for (i = 0; i < menuSize; i++) {
							menuOptions[i] = EMPTY;
							menuValues[i] = sliderValue;
						}
					}
					break;
				case MENU_ADJUSTMENT:
					menuOptions = result.result.names;
					menuValues = result.result.values;
					menuSize = result.result.values.length;
					break;
			}
			
			updateValues(result);
		}
		
		public static function updateValues(result:GFxResult) {
			var i:int;
			var len:int;

			switch (result.type)
			{
				case Data.RESULT_NAMES:
					len = result.result.length;
					for (i = 0; i < len; i++) {
						menuOptions[i] = result.result[i];
						menuValues[i] =  result.result[i];
					}
					break;
				case Data.RESULT_VALUES:
					len = result.result.length;
					for (i = 0; i < len; i++) {
						menuValues[i] = result.result[i];
					}
					break;
				case Data.RESULT_ITEMS:
					len = result.result.names.length;
					for (i = 0; i < len; i++) {
						menuOptions[i] = result.result.names[i];
					}
					len = result.result.values.length;
					for (i = 0; i < len; i++) {
						menuValues[i] = result.result.values[i];
					}
					break;
			}
		}
		
		public static function setMenuSize(length:int) {
			menuSize = length;
			menuOptions.length = length;
			menuValues.length = length;
		}
		
		public static function removeMenuIndex(index:int) {
			Data.menuOptions.splice(index, 1);
			Data.menuValues.splice(index, 1);
			Data.menuSize = Data.menuOptions.length;
		}

		public static function getType(index:int):int
		{
			switch (menuType) {
				case MENU_MAIN: return ITEM_LIST;
				case MENU_MIXED: return menuData.items[index].type;
				case MENU_CHECKBOX: return ITEM_CHECKBOX;
				case MENU_LIST: return ITEM_LIST;
				case MENU_SLIDER: return ITEM_SLIDER;
				case MENU_ADJUSTMENT: return ITEM_ADJUSTMENT;
				case MENU_FOLDER: return (menuFolder[index].folder ? ITEM_FOLDER : ITEM_LIST);
				case MENU_FOLDERCHECKBOX: 
				{
					if (menuFolder[index].folder) {
						return ITEM_FOLDER
					} else {
						return (locals.folderCheckbox ? ITEM_CHECKBOX : ITEM_LIST);
					}
				}				
			}
			
			return 0;
		}
		
		public static function getName(index:int):String
		{
			return menuOptions[index];
//			switch (menuType) {
//				case MENU_MAIN: return menuData.names[index];
//				case MENU_CHECKBOX: return menuData.names[index];
//				case MENU_MIXED: return menuData.items[index].name;
//			}
		}
		
		public static function getValue(index:int):Object
		{
			return menuValues[index];
		}
		
		public static function getInt(index:int):int
		{
			return menuValues[index];
		}
		
		public static function getFloat(index:int):Number
		{
			return menuValues[index];
		}
		
		public static function getString(index:int):String
		{
			return menuValues[index];
		}
		
		public static function getBool(index:int):Boolean
		{
			return menuValues[index];
		}
		
		public static function getCheckbox(index:int):Boolean
		{
			if (menuType == MENU_FOLDERCHECKBOX) {
				return menuFolder[index].checked;
			} else {
				return menuValues[index];
			}
		}
		
		public static function getHotkey(type:int):Object
		{
			switch (type) {
				case BUTTON_SAVE: if (menuData.save) return menuData.save; break;
				case BUTTON_LOAD: if (menuData.load) return menuData.load; break;
				case BUTTON_RESET: if (menuData.reset) return menuData.reset; break;
				case BUTTON_EXTRA: if (menuData.extra) return menuData.extra; break;
			}
			
			return null;
		}
		
		public static function getFolderHotkey(type:int):Object
		{
			switch (type) {
				case BUTTON_SAVE: if (folderData.save) return folderData.save; break;
				case BUTTON_LOAD: if (folderData.load) return folderData.load; break;
				case BUTTON_RESET: if (folderData.reset) return folderData.reset; break;
				case BUTTON_EXTRA: if (folderData.extra) return folderData.extra; break;
			}
			
			return null;
		}
		
		public static function getTouch(index:int):Object
		{
			var data:Object = menuData.items[index].touch;
			if (data)
				return data;
			
			return defaultTouchData;
		}
		
		public static function getSlider(index:int):Object
		{
			var data:Object = (menuType == MENU_SLIDER ? menuData.slider : menuData.items[index].slider);
			if (data)
				return data;
			
			return defaultSliderData;
		}
		
		public static function initLatents(func:Function)
		{
			for (var i:int = 0; i < LATENT_MAX; i++) {
				latentCallbacks[i] = new LatentCallback(func);
			}
			
			latentGet = latentCallbacks[0];
			latentNotification = latentCallbacks[1];
			latentTitle = latentCallbacks[2];
			latentSet = latentCallbacks[3];
		}
		
		public static function clearLatents()
		{
			for (var i:int = 0; i < LATENT_MAX; i++) {
				latentCallbacks[i].Clear();
			}
			
			latentMenuData = null;
			latentMenuName = null;
			latentWaiting = false;
		}
		
		public static function updateLatent(latent:LatentCallback, result:GFxResult, data:Object)
		{
			if (result) 
			{
				if (result.type == RESULT_WAITING) 
				{
					latent.Init(data.timeout);
					latentWaiting = true;
				}
				else
				{
					latent.Store(result);
				}
			}
			else {
				latent.Clear();
			}
		}
		
		public static function startLatents(data:Object, name:String, type:int):Boolean
		{
			if (!latentWaiting)
				return true;
				
			latentMenuData = data;
			latentMenuName = name;
			latentAction = type;
			
			var latent:LatentCallback;
			for (var i:int = 0; i < LATENT_MAX; i++) {
				latent = latentCallbacks[i];
				latent.Start();
			}
			
			return false;
		}
		
		public static function getDebugMenu(name:String):Object
		{
			switch (name) {
				
			case "Main": return {
				type: MENU_MAIN,
				names: [
					"$SAM_PoseAdjustMenu",
					"$SAM_SkeletonAdjustMenu",
					"$SAM_RaceAdjustMenu",
					"$SAM_PosePlayMenu",
					"$SAM_PoseExportMenu",
					"$SAM_PlayIdleMenu",
					"$SAM_PositionMenu",
					"$SAM_FaceMorphsMenu",
					"$SAM_EyesMenu",
					"$SAM_InventoryMenu",
					"$SAM_LightMenu",
					"$SAM_CameraMenu",
					"$SAM_HacksMenu",
					"$SAM_OptionsMenu",
					"$SAM_ExtensionsMenu"
				],
				values: [
					"PoseAdjustment",
					"SkeletonAdjustment",
					"RaceAdjustment",
					"SamPoses",
					"ExportType",
					"PlayIdle",
					"Positioning",
					"FaceMorphCategories",
					"Eyes",
					"Inventory",
					"Lights",
					"Camera",
					"Hacks",
					"Options",
					"Extensions"
				]
			};
			
			case "SkeletonAdjustment": return {
				type: MENU_FOLDER,
				folder: {
					"type": "full",
					"path": "Data\\F4SE\\Plugins\\SAM\\FaceMorphs",
					"ext": ".txt",
					"pop": false,
					"func": {
						"type": "local",
						"name": "LoadAdjustment"
					}
				}
			}
			
			case "Options": return {
				type: MENU_MIXED,
				get: {
					type: FUNC_SAM,
					name: "GetOptions"
				},
				set: {
					type: FUNC_SAM,
					name: "SetOptions"
				},
				update: true,
				items: [
					{
						name: "$SAM_Hotswap",
						type: ITEM_CHECKBOX
					},
					{
						name: "$SAM_Alignment",
						type: ITEM_CHECKBOX,
						func: {
							type: FUNC_LOCAL,
							name: "SetAlignment"
						}
					},
					{
						name: "$SAM_Widescreen",
						type: ITEM_CHECKBOX,
						func: {
							type: FUNC_LOCAL,
							name: "SetWidescreen"
						}
					}
				]
			};
			
			case "Eyes": return {
				"type": MENU_SLIDER,
				"update": true,
				"slider": {
					"type": VALUE_FLOAT,
					"min": -1.0,
					"max": 1.0,
					"step": 0.01,
					"stepkey": 0.05,
					"fixed": 4
				},
				"names": [
					"$SAM_EyeX",
					"$SAM_EyeY"
				],
				"get": {
					"type": FUNC_SAM,
					"name": "GetEyes"
				},
				"set": {
					"type": FUNC_DEBUG,
					"name": "SetEyes",
					"args": [
						{
							"type": ARGS_INDEX,
							"index": 0
						},
						{
							"type": ARGS_INDEX,
							"index": 1
						}
					]
				}
			};
			
			case "FaceMorphCategories": return {
				"type": MENU_LIST,
				"get": {
					"type": FUNC_SAM,
					"name": "GetFaceMorphCategories"
				},
				"set": {
					"type": FUNC_DEBUG,
					"name": "SetFaceMorphCategory",
					"var": "faceMorphCategory"
				},
				"reset": {
					"name": "$SAM_Reset",
					"type": "func",
					"func": {
						"type": "sam",
						"name": "ResetFaceMorphs"
					}
				},
				"save": {
					"name": "$SAM_Save",
					"type": "func",
					"func": {
						"type": "entry",
						"entry": {
							"func": {
								"type": "sam",
								"name": "SaveFaceMorphs"
							}
						}
					}
				},
				"load": {
					"name": "$SAM_Load",
					"type": "func",
					"func": {
						"type": "folder",
						"folder": {
							"type": "full",
							"path": "Data\\F4SE\\Plugins\\SAM\\FaceMorphs",
							"ext": ".txt",
							"pop": false,
							"func": {
								"type": "sam",
								"name": "LoadFaceMorphs"
							}
						}
					}
				}
			};
			
			case "Positioning": return {
				"type": MENU_MIXED,
				"get": {
					"type": FUNC_SAM,
					"name": "GetPositioning"
				},
				"set": {
					"type": FUNC_SAM,
					"name": "SetPositioning"
				},
				"update": true,
				"items": [
					{
						"name": "$SAM_Step",
						"type": ITEM_SLIDER,
						"slider": {
							"type": VALUE_INT,
							"min": 0,
							"max": 500,
							"step": 1,
							"stepkey": 1
						}
					},
					{
						"name": "$SAM_PosX",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 10.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_PosY",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 10.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_PosZ",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 10.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_RotX",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 2.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_RotY",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 2.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_RotZ",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 2.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_Scale",
						"type": ITEM_TOUCH,
						"touch": {
							"type": VALUE_FLOAT,
							"visible": true,
							"step": 1.0,
							"fixed": 2
						}
					},
					{
						"name": "$SAM_ResetPos",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_ResetRot",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_ResetScale",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_TGP",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_TCL",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_EnableFootIK",
						"type": ITEM_LIST
					},
					{
						"name": "$SAM_DisableFootIK",
						"type": ITEM_LIST
					}
				]
			};
			
			case "Inventory": return {
				type: MENU_LIST,
				names: [
					"Hello"
				],
				load: {
					"name": "$SAM_Load",
					"type": HOTKEY_FUNC,
					"func": {
						"type": FUNC_FOLDER,
						"folder": {
							"type": PATH_FULL,
							"path": "Data\\F4SE\\Plugins\\SAF\\Adjustments",
							"ext": ".json",
							"pop": false,
							"func": {
								"type": FUNC_DEBUG,
								"name": "LoadAdjustment"
							}
						}
					}
				},
				save: {
					"name": "$SAM_SAVE",
					"type": HOTKEY_FUNC,
					"func": {
						"type": FUNC_ENTRY,
						"entry": {
							"func": {
								"type": FUNC_DEBUG,
								"name": "SaveAdjustment"
							}
						}
					}
				}
			};
			
			case "FaceMorphSliders": return {
				"type": "slider",
				"slider": {
					"type": "int",
					"min": 0,
					"max": 100,
					"step": 1,
					"stepkey": 1
				},
				"get": {
					"type": FUNC_SAM,
					"name": "GetFaceMorphs",
					"args": [
						{
							"type": ARGS_VAR,
							"name": "faceMorphCategory"
						}
					]
				},
				"set": {
					"type": "sam",
					"name": "SetFaceMorph",
					"args": [
						{
							"type": "var",
							"name": "faceMorphCategory"
						}
					]
				},
				"reset": {
					"name": "$SAM_Reset",
					"type": "func",
					"func": {
						"type": "sam",
						"name": "ResetFaceMorphs"
					}
				},
				"save": {
					"name": "$SAM_Save",
					"type": "func",
					"func": {
						"type": "entry",
						"entry": {
							"func": {
								"type": "sam",
								"name": "SaveFaceMorphs"
							}
						}
					}
				},
				"load": {
					"name": "$SAM_Load",
					"type": "func",
					"func": {
						"type": "folder",
						"folder": {
							"type": "full",
							"path": "Data\\F4SE\\Plugins\\SAM\\FaceMorphs",
							"ext": ".txt",
							"pop": false,
							"func": {
								"type": "sam",
								"name": "LoadFaceMorphs"
							}
						}
					}
				}
			};
			
			case "TongueBones": return {
				"type": MENU_LIST,
				"get": {
					"type": FUNC_SAM,
					"name": "GetTongueBones"
				},
				"set": {
					"type": FUNC_MENU,
					"name": "BoneEdit",
					"var": "boneName"
				}
			};
						
			}
			
			error = "$SAM_MenuMissing";
			return null;
		}
		
		public static function getSamDebugFunction(name:String):GFxResult
		{
			switch (name)
			{
				
			case "GetOptions": return new GFxResult(RESULT_VALUES, [
				false, false, false
			]);
			
			case "GetPositioning": return new GFxResult(RESULT_VALUES, [
				 100, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 1.0
			]);
			
			case "GetEyes": return new GFxResult(RESULT_VALUES, [
				0.0, 0.0
			]);
			
			case "GetFaceMorphCategories": return new GFxResult(RESULT_ITEMS, new GFxItems(
				["Lips", "Jaw", "Eyes","Eyebrows", "Tongue Bones"],
				[0, 1, 2, 3, 4]
			));
			
			case "GetTongueBones": return new GFxResult(RESULT_ITEMS, {
				names: ["Tongue 0", "Tongue 1", "Tongue 2"],
				values: [0, 1, 2]
			});
			
//			case "GetFolder": return new GFxResult(RESULT_FOLDER, [
//				{
//					name: "folder",
//					path: "test",
//					folder: true
//				},
//				{
//					name: "file",
//					path: "test2",
//					folder: false
//				}
//			]);
			
			}

			error = "$SAM_SamFunctionMissing";
			return null;
		}
		
		public static function load(data:Object, samObj:Object, f4seObj:Object, stageObj:DisplayObject)
		{
			sam = samObj;
			f4se = f4seObj;
			stage = stageObj;
			
			if (data.saved) {
				menuOptions = data.saved.options;
				menuValues = data.saved.values;
				menuSize = data.saved.size;
				folderStack = data.saved.folderStack;
				menuFolder = data.saved.folder;
				locals = data.saved.locals;
				menuData = data.saved.menuData;
				entryData = data.saved.entryData;
				folderData = data.saved.folderData;
				holdData = data.saved.holdData;
				menuType = data.saved.menuType;
			}
		}
		
		public static function saveState(data:Object)
		{
			data.options = menuOptions;
			data.values = menuValues;
			data.size = menuSize
			data.folderStack = folderStack;
			data.folder = menuFolder;
			data.locals = locals;
			data.menuData = menuData;
			data.entryData = entryData;
			data.folderData = folderData;
			data.holdData = holdData;
			data.menuType = menuType;
			
			try 
			{
				sam.SaveState(data);
			}
			catch (e:Error)
			{
				trace("Failed to save state");
			}
		}
		
		public static function clearState()
		{
			try {
				sam.ClearState();
			}
			catch (e:Error)
			{
				trace("Failed to clear state");
			}
		}
		
		public static function setCursorVisible(visible:Boolean)
		{
			try 
			{
				sam.SetCursorVisible(visible);
			}
			catch(e:Error)
			{
				trace("Failed to set cursor visibility");
			}
		}
		
		public static function storeCursorPos()
		{
			try {
				var result:GFxResult = sam.GetCursorPosition();
				
				if (result.type == RESULT_VALUES) {
					cursorStored = true;
					cursorPosX = result.result[0];
					cursorPosY = result.result[1];
					return;
				}
			}
			catch (e:Error)
			{
				trace("Failed to store cursor pos");
			}
			
			cursorStored = false;
		}
		
		public static function updateCursorDrag():int
		{
			if (cursorStored) {
				try 
				{
					var result:GFxResult = sam.GetCursorPosition();
					if (result.type == RESULT_VALUES) {
						sam.SetCursorPosition(cursorPosX, cursorPosY);
						return result.result[0] - cursorPosX;
					}
				}
				catch (e:Error)
				{
					trace("Failed to update cursor pos");
				}
			}
			
			return 0;
		}
		
		public static function endCursorDrag()
		{
			cursorStored = false;
		}
		
		public static function toggleMenu():Boolean
		{
			try
			{
				return sam.ToggleMenus();
			}
			catch (e:Error)
			{
				trace("Failed to hide menus");
			}
			return false;
		}
				
		public static function setAdjustmentPersistent(persistent:Boolean)
		{
			try
			{
				sam.SetAdjustmentPersistence(selectedAdjustment, persistent);
			}
			catch (e:Error)
			{
				trace("Failed to set adjustment persistence");
			}
		}
		
		public static function setAdjustmentScale(scale:int)
		{
			try
			{
				sam.SetAdjustmentScale(selectedAdjustment, scale);
			}
			catch (e:Error)
			{
				trace("Failed to set adjustment weight");
			}
		}
		
		public static function resetAdjustment()
		{
			try
			{
				sam.ResetAdjustment(selectedAdjustment);
			}
			catch (e:Error)
			{
				trace("Failed to reset adjustment");
			}
		}
		
		public static function removeAdjustment(id:int)
		{
			try
			{
				sam.RemoveAdjustment(id);
			}
			catch (e:Error)
			{
				trace("Failed to remove adjustment");
			}
		}
				
		public static function moveAdjustment(id:int, inc:Boolean):Boolean
		{
			try
			{
				return sam.MoveAdjustment(menuValues[id], inc);
			}
			catch (e:Error)
			{
				trace("Failed to move adjustment");
			}
			return false;
		}
		
		public static function getNodeName()
		{
			try {
				boneName = sam.GetNodeNameFromIndexes(selectedCategory, selectedBone);
			}
			catch (e:Error)
			{
				trace("Failed to get node");
				boneName = "";
			}
		}
		
		public static function getNodeIsOffset() : Boolean
		{
			try {
				return sam.GetNodeIsOffset(boneName);
			}
			catch (e:Error) {
				trace("Failed to check if node is offset");
			}
			return true;
		}
		
		public static function toggleNodeName() : Boolean
		{
			try {
				boneName = sam.ToggleNodeName(boneName);
				return true;
			}
			catch (e:Error) {
				trace("Failed to toggle node name");
			}
			return false;
		}
		
		public static function getIdleName():String
		{
			try {
				return sam.GetIdleName();
			}
			catch (e:Error)
			{
				trace("Failed to get idle name");
			}
			return null;
		}
				
		public static function updateFolderNames():Array
		{
			setMenuSize(menuFolder.length);
			for (var i:int = 0; i < menuFolder.length; i++) {
				menuOptions[i] = menuFolder[i].name;
			}
		}
		
		public static function getFolder(path:String, ext:String):GFxResult
		{
			try {
				var result:GFxResult = sam.GetFolder(path, ext);
				
				if (result && result.type == RESULT_FOLDER)
					return result;
			}
			catch (e:Error) {}
			
			if (Util.debug) {
				var debugFolder:Object = getDebugFolder(path);
				if (debugFolder)
					return new GFxResult(RESULT_FOLDER, debugFolder);
			}
			
			error = "Failed to get folder";
			return null;
		}
		
		//Hard coded to work with skeleton/race adjustments menus
		public static function getFolderCheckbox(path:String, ext:String, race:Boolean):GFxResult
		{
			try {
				var result:GFxResult = sam.GetSkeletonAdjustments(path, ext, race);
				
				if (result && result.type == RESULT_FOLDERCHECKBOX)
					return result;
			}
			catch (e:Error) {}

			error = "Failed to get folder";
			return null;
		}
		
		public static function setFolder(data:Object, result:GFxResult)
		{
			//trace("set folder");
			menuType = (result.type == RESULT_FOLDERCHECKBOX ? MENU_FOLDERCHECKBOX : MENU_FOLDER);
			folderData = data;
			//Util.traceObj(folderData);
			//folderStack.length = 0;
			menuFolder = result.result;
			//Util.traceObj(menuFolder);
			updateFolderNames();
		}
		
		public static function pushFolder(path:String, result:Object)
		{
			folderStack.push(path);
			updateFolder(result);
		}
		
		public static function getCurrentFolder():String
		{
			return (folderStack.length == 0 ? Data.folderData.path : folderStack[folderStack.length - 1]);
		}
		
		public static function popFolder():String
		{
			folderStack.pop();
			return getCurrentFolder();
		}
		
		public static function updateFolder(result:Object)
		{
			menuFolder = result;
			updateFolderNames();
		}
		
		public static function getFolderPath(i:int)
		{
			try {
				switch(folderData.format) {
					case PATH_FILE:
						var fileResult:GFxResult = sam.GetPathStem(menuFolder[i].path);
						if (fileResult && fileResult.type == RESULT_STRING)
							return fileResult.result;
						break;
						
					case PATH_RELATIVE:
						var relativeResult:GFxResult = sam.GetPathRelative(menuFolder[i].path, folderData.path, folderData.ext);
						if (relativeResult && relativeResult.type == RESULT_STRING)
							return relativeResult.result;
						break;
						
					case PATH_FULL:
						return menuFolder[i].path;
				}
			}
			catch (e:Error) {
				trace(e.message);
			}
			
			return EMPTY;
		}
		
		public static function getDebugFolder(path:String)
		{
			return [
				{
					"name": "Folder",
					"folder": true,
					"path": "test"
				},
				{
					"name": "File",
					"folder": false,
					"path": "test"
				}
			];

			return null;
		}
		
		public static function getLightVisible(selectedLight:int):Boolean
		{
			try
			{
				return sam.GetLightVisible(selectedLight);
			}
			catch (e:Error)
			{
				trace("Failed to get light visibility");
			}
			
			return false;
		}
		
		public static function toggleLightVisible(selectedLight:int):Boolean
		{
			try
			{
				return sam.ToggleLightVisible(selectedLight);
			}
			catch (e:Error)
			{
				trace("Failed to toggle light visiblity");
				return true;
			}
		}
		
		public static function getAllLightsVisible():Boolean
		{
			try
			{
				return sam.GetAllLightsVisible();
			}
			catch (e:Error)
			{
				trace("Failed to get light visibility");
				return false;
			}
		}
		
		public static function toggleAllLightsVisible():Boolean
		{
			try
			{
				return sam.ToggleAllLightsVisible();
			}
			catch (e:Error)
			{
				trace("Failed to toggle lights visibility");
				return true;
			}
		}
	}
}