#pragma once

#include "common/IFileStream.h"

#include "adjustments.h"
#include "util.h"

#include "json/json.h"

#include <regex>

#define ADJUSTMENTS_PATH "Data\\F4SE\\Plugins\\SAF\\Adjustments"
#define POSES_PATH "Data\\F4SE\\Plugins\\SAF\\Poses"
#define SETTINGS_PATH "Data\\F4SE\\Plugins\\SAF\\settings.json"
#define NODEMAPS_PATH "Data\\F4SE\\Plugins\\SAF\\NodeMaps"
#define DEFAULT_PATH "Data\\F4SE\\Plugins\\SAF\\Default"

#define WriteJsonFloat(K, V, D) sprintf_s(buffer, D, V); \
K = Json::Value(buffer);

extern std::regex tabSeperatedRegex;
extern std::regex tabOptionalRegex;

typedef std::vector<std::pair<std::string, std::string>> MenuList;
typedef std::vector<std::pair<std::string, MenuList>> MenuCategoryList;
typedef std::unordered_map<UInt64, MenuCategoryList> MenuCache;

namespace SAF {

	struct MenuHeader
	{
		std::string form;
		std::string mod;
		bool isFemale = false;
		UInt32 type = 0;
	};

	class TsvReader {
	public:

		MenuHeader header;
		std::string path;
		UInt32 categoryIndex;
		InsensitiveUInt32Map* typeMap;
		UInt64 key;

		TsvReader(std::string p, InsensitiveUInt32Map* t) :
			path(p),
			categoryIndex(0),
			typeMap(t),
			key(0)
		{};

		bool Read();

		virtual void ReadHeader(std::string m1, std::string m2);
		virtual bool FinalizeHeader(std::string m1, std::string m2) { return true; }
		virtual void ReadCategory(std::string m1, std::string m2) {}
		virtual void ReadLine(std::string m1, std::string m2) {}
	};

	enum {
		kMenuHeaderForm = 1,
		kMenuHeaderMod,
		kMenuHeaderSex,
		kMenuHeaderType
	};

	extern InsensitiveUInt32Map menuHeaderMap;

	enum {
		kGenderMale = 0,
		kGenderFemale
	};

	extern InsensitiveUInt32Map genderMap;

	void ReadAll(IFileStream* file, std::string* str);
	float ReadJsonFloat(Json::Value& value);
	void LoadAllFiles();
	bool SaveAdjustmentFile(const char* filename, std::shared_ptr<Adjustment> adjustment);
	bool LoadAdjustmentFile(const char* filename, LoadedAdjustment* map);
	bool LoadAdjustmentPath(const char* path, LoadedAdjustment* map);
	bool SavePoseFile(const char* file, TransformMap* poseMap, const char* skeleton);
	bool LoadPoseFile(const char* file, TransformMap* poseMap);
	bool LoadPosePath(const char* path, TransformMap* poseMap);
	bool SaveOutfitStudioXml(const char* path, TransformMap* poseMap);
}