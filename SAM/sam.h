#pragma once

#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/GameTypes.h"
#include "f4se/PluginAPI.h"
#include "f4se/GameForms.h"
#include "f4se/ScaleformValue.h"
#include "f4se/ScaleformMovie.h"

#include "json.h"

#include <unordered_map>

class SelectedRefr {
public:
	TESObjectREFR* refr;
	UInt32 formId;
	NiAVObject* eyeNode;
	bool isFemale;
	UInt32 race;
	UInt64 key;

	//virtual TESObjectREFR* Refr();
	virtual void Update(TESObjectREFR* refr);
	virtual void Clear();
};

extern SelectedRefr selected;

class SavedMenuData {
public:
	TESObjectREFR* refr;
	Json::Value data;

	void Save(GFxValue* data);
	bool Load(GFxMovieRoot* root, GFxValue* res);
	void Clear();

	void GetGFxValue(GFxMovieRoot* root, GFxValue* result, const Json::Value& value);
};

extern SavedMenuData saveData;

typedef std::vector<std::pair<std::string, std::string>> MenuList;
typedef std::vector<std::pair<std::string, MenuList>> MenuCategoryList;
typedef std::unordered_map<UInt64, MenuCategoryList> MenuCache;

struct MenuOptions {
	bool hotSwapping = false;
};

extern MenuOptions menuOptions;

enum {
	kSamOptionHotswap = 1
};

extern MenuCache poseMenuCache;
extern MenuCache morphsMenuCache;
extern MenuCache groupsMenuCache;

TESObjectREFR* GetRefr();

MenuCategoryList* GetMenu(MenuCache* cache);

void GetOptionsGFx(GFxMovieRoot* root, GFxValue* result);

void SetMenuVisible(BSFixedString menuName, const char* visiblePath, bool visible);

bool GetCursor(SInt32* pos);
bool SetCursor(SInt32 x, SInt32 y);
void GetCursorPositionGFx(GFxMovieRoot* root, GFxValue* result);

void OnMenuOpen();
void OnMenuClose();
void OnConsoleRefUpdate();

void ToggleMenu();
bool OpenSamFile(std::string filename);

void LoadMenuFiles();