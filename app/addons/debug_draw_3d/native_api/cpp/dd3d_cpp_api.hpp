#pragma once

// This file is generated!
//
// To create new instances of Ref<T>, where T is the DD3D class, use std::make_shared<T>, e.g.:
//   auto cfg = std::make_shared<DebugDraw3DConfig>();
//
// Functions with strings and arrays also have an additional "_c" version of functions for native arrays.
// The "_c" version only accepts `utf8` strings.
//
// Define DD3D_ENABLE_MISMATCH_CHECKS to enable signature mismatch checking
//
// Define FORCED_DD3D to ignore the lack of DEBUG_ENABLED.

//#define DD3D_ENABLE_MISMATCH_CHECKS
//#define FORCED_DD3D

#if defined(DEBUG_ENABLED) || defined(FORCED_DD3D)
#define _DD3D_RUNTIME_CHECK_ENABLED
#endif

#include <memory>

#if _MSC_VER
__pragma(warning(disable : 4244 26451 26495));
#endif
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/font.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/builtin_types.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#if _MSC_VER
__pragma(warning(default : 4244 26451 26495));
#endif

#ifndef ZoneScoped
#define _NoProfiler
#define ZoneScoped
#endif


#ifdef DD3D_ENABLE_MISMATCH_CHECKS
#include <sstream>
#include <string>
#include <typeinfo>
#endif

namespace DD3DShared {

#ifdef DD3D_ENABLE_MISMATCH_CHECKS
template <typename T>
struct FunctionSignature;

template <typename R, typename... Args>
struct FunctionSignature<R (*)(Args...)> {
	static godot::String get() {
		std::ostringstream oss;
		oss << typeid(R).name() << " (";
		((oss << getTypeName<Args>() << ", "), ...);
		return godot::String(oss.str().c_str()).trim_suffix(", ") + ")";
	}

private:
	template <typename U>
	static std::string getTypeName() {
		std::ostringstream oss;
		if constexpr (std::is_const<U>::value) {
			oss << "const ";
		}
		if constexpr (std::is_reference<U>::value) {
			oss << getTypeName<std::remove_reference_t<U>>() << "&";
		} else {
			oss << typeid(U).name();
		}
		return oss.str();
	}
};
#endif

struct CQuaternion {
	real_t x = 0.0;
	real_t y = 0.0;
	real_t z = 0.0;
	real_t w = 1.0;

	_FORCE_INLINE_ operator godot::Quaternion() const {
		return godot::Quaternion(x, y, z, w);
	}

	CQuaternion(const godot::Quaternion &q) :
			x(q.x), y(q.y), z(q.z), w(q.w) {
	}
};

struct CProjection {
	godot::Vector4 columns[4];

	_FORCE_INLINE_ operator godot::Projection() const {
		return godot::Projection(columns[0], columns[1], columns[2], columns[3]);
	}

	CProjection(const godot::Projection &p) {
		columns[0] = p[0];
		columns[1] = p[1];
		columns[2] = p[2];
		columns[3] = p[3];
	}
};

} // namespace DD3DShared


struct _DD3D_Loader_ {
	static constexpr const char *log_prefix = "[DD3D C++] ";
	static constexpr const char *get_funcs_is_double_name = "_get_native_functions_is_double";
	static constexpr const char *get_funcs_hash_name = "_get_native_functions_hash";
	static constexpr const char *get_funcs_name = "_get_native_functions";

	enum class LoadingResult {
		None,
		Success,
		Failure
	};

	static godot::Object *get_dd3d() {
		ZoneScoped;

		static godot::Object *dd3d_c = nullptr;
		static bool failed_to_load = false;

		if (failed_to_load)
			return nullptr;

		if (dd3d_c)
			return dd3d_c;

		if (godot::Engine::get_singleton()->has_singleton("DebugDrawManager")) {
			godot::Object *dd3d = godot::Engine::get_singleton()->get_singleton("DebugDrawManager");

			if (!dd3d->has_method(get_funcs_is_double_name)) {
				godot::UtilityFunctions::printerr(log_prefix, get_funcs_is_double_name, " not found!");
				failed_to_load = true;
				return nullptr;
			}

#ifdef REAL_T_IS_DOUBLE
			bool is_double = true;
#else
			bool is_double = false;
#endif
			if ((bool)dd3d->call(get_funcs_is_double_name) != is_double) {
				godot::UtilityFunctions::printerr(log_prefix, "The precision of Vectors and Matrices of DD3D and the current library do not match!");
				failed_to_load = true;
				return nullptr;
			}

			if (!dd3d->has_method(get_funcs_hash_name)) {
				godot::UtilityFunctions::printerr(log_prefix, get_funcs_hash_name, " not found!");
				failed_to_load = true;
				return nullptr;
			}

			if (!dd3d->has_method(get_funcs_name)) {
				godot::UtilityFunctions::printerr(log_prefix, get_funcs_name, " not found!");
				failed_to_load = true;
				return nullptr;
			}

			dd3d_c = dd3d;
		} else {
			ERR_PRINT(godot::String(log_prefix) + "DebugDrawManager not found! Most likely, DebugDraw3D was not loaded correctly.");
			failed_to_load = true;
		}
		return dd3d_c;
	}

	static bool load_function(int64_t &val, const godot::String &sign2, const char *name) {
		ZoneScoped;
		if (godot::Object *dd3d = get_dd3d(); dd3d) {
			int64_t api_hash = dd3d->call(get_funcs_hash_name);

			// TODO: add an actual comparison with the previous hash. It is useful in case of library reloading, but is it really useful for users?..
			if (api_hash != 0) {
				godot::Dictionary api = dd3d->call(get_funcs_name);
				if (api.has(name)) {
					godot::Dictionary func_dict = api[name];

#ifdef DD3D_ENABLE_MISMATCH_CHECKS
					godot::String sign1 = func_dict.get("signature", "");
					//godot::UtilityFunctions::print(log_prefix, "FUNCTION SIGNATURE\n\tFunc name:\t", name, "\n\tDD3D Sign:\t", sign1, "\n\tClient Sign:\t", sign2);

					if (!sign1.is_empty() && sign1 != sign2) {
						godot::UtilityFunctions::printerr(log_prefix, "!!! FUNCTION SIGNATURE MISMATCH !!!\n\tFunc name:\t", name, "\n\tDD3D Sign:\t", sign1, "\n\tClient Sign:\t", sign2);
						return false;
					}
#endif
					val = (int64_t)func_dict["ptr"];
					return true;
				} else {
					godot::UtilityFunctions::printerr(log_prefix, "!!! FUNCTION NOT FOUND !!! function name: ", name);
					return false;
				}
			}
		}
		return false;
	}
};

#ifdef DD3D_ENABLE_MISMATCH_CHECKS
#define FUNC_GET_SIGNATURE(func_name) DD3DShared::FunctionSignature<decltype(func_name)>::get()
#else
#define FUNC_GET_SIGNATURE(func_name) ""
#endif

#define LOADING_RESULT static _DD3D_Loader_::LoadingResult _dd3d_loading_result = _DD3D_Loader_::LoadingResult::None
#define IS_FIRST_LOADING _dd3d_loading_result == _DD3D_Loader_::LoadingResult::None
#define IS_LOADED_SUCCESSFULLY _dd3d_loading_result == _DD3D_Loader_::LoadingResult::Success
#define IS_FAILED_TO_LOAD _dd3d_loading_result == _DD3D_Loader_::LoadingResult::Failure
#define LOAD_FUNC_AND_STORE_RESULT(_name)                                                                                                                                                   \
	int64_t _dd3d_func_ptr = 0;                                                                                                                                                             \
	_dd3d_loading_result = _DD3D_Loader_::load_function(_dd3d_func_ptr, FUNC_GET_SIGNATURE(_name), #_name) ? _DD3D_Loader_::LoadingResult::Success : _DD3D_Loader_::LoadingResult::Failure; \
	if (IS_LOADED_SUCCESSFULLY) {                                                                                                                                                           \
		_name = reinterpret_cast<decltype(_name)>(_dd3d_func_ptr);                                                                                                                          \
	}

#define LOAD_AND_CALL_FUNC_POINTER(_name, ...) \
	ZoneScoped;                                \
	LOADING_RESULT;                            \
	if (IS_FIRST_LOADING) {                    \
		LOAD_FUNC_AND_STORE_RESULT(_name);     \
		if (IS_FAILED_TO_LOAD) {               \
			return;                            \
		}                                      \
	}                                          \
	if (IS_LOADED_SUCCESSFULLY) {              \
		_name(__VA_ARGS__);                    \
	}

#define LOAD_AND_CALL_FUNC_POINTER_SELFRET(_name, ...) \
	ZoneScoped;                                        \
	LOADING_RESULT;                                    \
	if (IS_FIRST_LOADING) {                            \
		LOAD_FUNC_AND_STORE_RESULT(_name);             \
		if (IS_FAILED_TO_LOAD) {                       \
			return shared_from_this();                 \
		}                                              \
	}                                                  \
	if (IS_LOADED_SUCCESSFULLY) {                      \
		_name(__VA_ARGS__);                            \
	}

#define LOAD_AND_CALL_FUNC_POINTER_RET(_name, _def_ret_val, ...) \
	ZoneScoped;                                                  \
	LOADING_RESULT;                                              \
	if (IS_FIRST_LOADING) {                                      \
		LOAD_FUNC_AND_STORE_RESULT(_name);                       \
		if (IS_FAILED_TO_LOAD) {                                 \
			return _def_ret_val;                                 \
		}                                                        \
	}                                                            \
	if (IS_LOADED_SUCCESSFULLY) {                                \
		return _name(__VA_ARGS__);                               \
	}                                                            \
	return _def_ret_val

#define LOAD_AND_CALL_FUNC_POINTER_RET_CAST(_name, _ret_cast, _def_ret_val, ...) \
	ZoneScoped;                                                                  \
	LOADING_RESULT;                                                              \
	if (IS_FIRST_LOADING) {                                                      \
		LOAD_FUNC_AND_STORE_RESULT(_name);                                       \
		if (IS_FAILED_TO_LOAD) {                                                 \
			return _def_ret_val;                                                 \
		}                                                                        \
	}                                                                            \
	if (IS_LOADED_SUCCESSFULLY) {                                                \
		return static_cast<_ret_cast>(_name(__VA_ARGS__));                       \
	}                                                                            \
	return _def_ret_val

#define LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_OBJECT(_name, godot_object_type, _def_ret_val, ...)             \
	ZoneScoped;                                                                                              \
	LOADING_RESULT;                                                                                          \
	if (IS_FIRST_LOADING) {                                                                                  \
		LOAD_FUNC_AND_STORE_RESULT(_name);                                                                   \
		if (IS_FAILED_TO_LOAD) {                                                                             \
			return _def_ret_val;                                                                             \
		}                                                                                                    \
	}                                                                                                        \
	if (IS_LOADED_SUCCESSFULLY) {                                                                            \
		return godot::Object::cast_to<godot_object_type>(godot::ObjectDB::get_instance(_name(__VA_ARGS__))); \
	}                                                                                                        \
	return _def_ret_val

#define LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_REF(_name, godot_ref_type, _def_ret_val, ...)                                            \
	ZoneScoped;                                                                                                                       \
	LOADING_RESULT;                                                                                                                   \
	if (IS_FIRST_LOADING) {                                                                                                           \
		LOAD_FUNC_AND_STORE_RESULT(_name);                                                                                            \
		if (IS_FAILED_TO_LOAD) {                                                                                                      \
			return _def_ret_val;                                                                                                      \
		}                                                                                                                             \
	}                                                                                                                                 \
	if (IS_LOADED_SUCCESSFULLY) {                                                                                                     \
		return godot::Ref<godot_ref_type>(godot::Object::cast_to<godot_ref_type>(godot::ObjectDB::get_instance(_name(__VA_ARGS__)))); \
	}                                                                                                                                 \
	return _def_ret_val

#define LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(_name, _cls, _def_ret_val, ...) \
	ZoneScoped;                                                                      \
	LOADING_RESULT;                                                                  \
	if (IS_FIRST_LOADING && !_name) {                                                \
		LOAD_FUNC_AND_STORE_RESULT(_name);                                           \
		if (IS_FAILED_TO_LOAD) {                                                     \
			return _def_ret_val;                                                     \
		}                                                                            \
	}                                                                                \
	if (IS_LOADED_SUCCESSFULLY) {                                                    \
		return std::make_shared<_cls>(_name(__VA_ARGS__));                           \
	}                                                                                \
	return _def_ret_val

class DebugDraw2DConfig;
class DebugDraw2DStats;
class DebugDraw3DConfig;
class DebugDraw3DScopeConfig;
class DebugDraw3DStats;

// Start of the generated API
static_assert(std::is_standard_layout_v<godot::Vector2>);
static_assert(std::is_trivially_copyable_v<godot::Vector2>);

static_assert(std::is_standard_layout_v<godot::Vector2i>);
static_assert(std::is_trivially_copyable_v<godot::Vector2i>);

static_assert(std::is_standard_layout_v<godot::Rect2>);
static_assert(std::is_trivially_copyable_v<godot::Rect2>);

static_assert(std::is_standard_layout_v<godot::Rect2i>);
static_assert(std::is_trivially_copyable_v<godot::Rect2i>);

static_assert(std::is_standard_layout_v<godot::Vector3>);
static_assert(std::is_trivially_copyable_v<godot::Vector3>);

static_assert(std::is_standard_layout_v<godot::Vector3i>);
static_assert(std::is_trivially_copyable_v<godot::Vector3i>);

static_assert(std::is_standard_layout_v<godot::Transform2D>);
static_assert(std::is_trivially_copyable_v<godot::Transform2D>);

static_assert(std::is_standard_layout_v<godot::Vector4>);
static_assert(std::is_trivially_copyable_v<godot::Vector4>);

static_assert(std::is_standard_layout_v<godot::Vector4i>);
static_assert(std::is_trivially_copyable_v<godot::Vector4i>);

static_assert(std::is_standard_layout_v<godot::Plane>);
static_assert(std::is_trivially_copyable_v<godot::Plane>);

// Original type - godot::Quaternion
static_assert(std::is_standard_layout_v<DD3DShared::CQuaternion>);
static_assert(std::is_trivially_copyable_v<DD3DShared::CQuaternion>);

static_assert(std::is_standard_layout_v<godot::AABB>);
static_assert(std::is_trivially_copyable_v<godot::AABB>);

static_assert(std::is_standard_layout_v<godot::Basis>);
static_assert(std::is_trivially_copyable_v<godot::Basis>);

static_assert(std::is_standard_layout_v<godot::Transform3D>);
static_assert(std::is_trivially_copyable_v<godot::Transform3D>);

// Original type - godot::Projection
static_assert(std::is_standard_layout_v<DD3DShared::CProjection>);
static_assert(std::is_trivially_copyable_v<DD3DShared::CProjection>);

static_assert(std::is_standard_layout_v<godot::Color>);
static_assert(std::is_trivially_copyable_v<godot::Color>);


/**
 * @brief
 * This is a class for storing part of the DebugDraw2D configuration.
 *
 * You can use DebugDraw2D.get_config to get the current instance of the configuration.
 */
class DebugDraw2DConfig {
public:
	enum BlockPosition : uint32_t {
		POSITION_LEFT_TOP = 0,
		POSITION_RIGHT_TOP = 1,
		POSITION_LEFT_BOTTOM = 2,
		POSITION_RIGHT_BOTTOM = 3,
	};

private:
	void *inst_ptr;

public:
	DebugDraw2DConfig(void *inst_ptr) :
			inst_ptr(inst_ptr) {}

	DebugDraw2DConfig(bool instantiate = true) :
			inst_ptr(instantiate ? create() : create_nullptr()) {}

	~DebugDraw2DConfig() { destroy(inst_ptr); }

	operator void *() const { return inst_ptr; }

	/**
	 * Position of the text block
	 */
	void set_text_block_position(const DebugDraw2DConfig::BlockPosition &_position) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_block_position)(void * /*inst_ptr*/, uint32_t /*DebugDraw2DConfig::BlockPosition _position*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_block_position, inst_ptr, static_cast<uint32_t>(_position));
#endif
	}

	DebugDraw2DConfig::BlockPosition get_text_block_position() {
		static uint32_t /*DebugDraw2DConfig::BlockPosition*/ (*DebugDraw2DConfig_get_text_block_position)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET_CAST(DebugDraw2DConfig_get_text_block_position, DebugDraw2DConfig::BlockPosition, {}, inst_ptr);
	}

	/**
	 * Offset from the corner selected in 'set_text_block_position'
	 */
	void set_text_block_offset(const godot::Vector2i &_offset) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_block_offset)(void * /*inst_ptr*/, const godot::Vector2i /*_offset*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_block_offset, inst_ptr, _offset);
#endif
	}

	godot::Vector2i get_text_block_offset() {
		static godot::Vector2i (*DebugDraw2DConfig_get_text_block_offset)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_block_offset, {}, inst_ptr);
	}

	/**
	 * Text padding for each line
	 */
	void set_text_padding(const godot::Vector2i &_padding) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_padding)(void * /*inst_ptr*/, const godot::Vector2i /*_padding*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_padding, inst_ptr, _padding);
#endif
	}

	godot::Vector2i get_text_padding() {
		static godot::Vector2i (*DebugDraw2DConfig_get_text_padding)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_padding, {}, inst_ptr);
	}

	/**
	 * How long the text remains visible after creation.
	 */
	void set_text_default_duration(const real_t &_duration) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_default_duration)(void * /*inst_ptr*/, const real_t /*_duration*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_default_duration, inst_ptr, _duration);
#endif
	}

	real_t get_text_default_duration() {
		static real_t (*DebugDraw2DConfig_get_text_default_duration)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_default_duration, {}, inst_ptr);
	}

	/**
	 * Default text size
	 */
	void set_text_default_size(const int &_size) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_default_size)(void * /*inst_ptr*/, const int /*_size*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_default_size, inst_ptr, _size);
#endif
	}

	int get_text_default_size() {
		static int (*DebugDraw2DConfig_get_text_default_size)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_default_size, {}, inst_ptr);
	}

	/**
	 * Default color of the text
	 */
	void set_text_foreground_color(const godot::Color &_new_color) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_foreground_color)(void * /*inst_ptr*/, const godot::Color /*_new_color*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_foreground_color, inst_ptr, _new_color);
#endif
	}

	godot::Color get_text_foreground_color() {
		static godot::Color (*DebugDraw2DConfig_get_text_foreground_color)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_foreground_color, {}, inst_ptr);
	}

	/**
	 * Background color of the text
	 */
	void set_text_background_color(const godot::Color &_new_color) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_background_color)(void * /*inst_ptr*/, const godot::Color /*_new_color*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_background_color, inst_ptr, _new_color);
#endif
	}

	godot::Color get_text_background_color() {
		static godot::Color (*DebugDraw2DConfig_get_text_background_color)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_get_text_background_color, {}, inst_ptr);
	}

	/**
	 * Custom text Font
	 */
	void set_text_custom_font(const godot::Ref<godot::Font> &_custom_font) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DConfig_set_text_custom_font)(void * /*inst_ptr*/, const uint64_t /*_custom_font*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_set_text_custom_font, inst_ptr, _custom_font.is_valid() ? _custom_font->get_instance_id() : 0);
#endif
	}

	godot::Ref<godot::Font> get_text_custom_font() {
		static const uint64_t (*DebugDraw2DConfig_get_text_custom_font)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_REF(DebugDraw2DConfig_get_text_custom_font, godot::Font, {}, inst_ptr);
	}

private:
	static void * create() {
		static void * (*DebugDraw2DConfig_create)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_create, nullptr);
	}

	static void * create_nullptr() {
		static void * (*DebugDraw2DConfig_create_nullptr)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DConfig_create_nullptr, nullptr);
	}

	static void destroy(void * inst_ptr) {
		static void (*DebugDraw2DConfig_destroy)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DConfig_destroy, inst_ptr);
	}

}; // class DebugDraw2DConfig

/**
 * @brief
 * Singleton class for calling debugging 2D methods.
 *
 * Currently, this class supports drawing an overlay with text.
 */
namespace DebugDraw2D {
/**
 * Set whether debug drawing works or not.
 */
static void set_debug_enabled(const bool &_state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_set_debug_enabled)(const bool /*_state*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_set_debug_enabled, _state);
#endif
}

static bool is_debug_enabled() {
	static bool (*DebugDraw2D_is_debug_enabled)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2D_is_debug_enabled, {});
}

/**
 * Set the configuration global for everything in DebugDraw2D.
 */
static void set_config(const std::shared_ptr<DebugDraw2DConfig> &_cfg) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_set_config)(void * /*_cfg*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_set_config, *_cfg);
#endif
}

/**
 * Get the DebugDraw2DConfig.
 */
static std::shared_ptr<DebugDraw2DConfig> get_config() {
	static void * (*DebugDraw2D_get_config)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw2D_get_config, DebugDraw2DConfig, nullptr);
}

/**
 * Set a custom Control to be used as the canvas for drawing the graphic.
 *
 * You can use any Control, even one that is in a different window.
 */
static void set_custom_canvas(const godot::Control * _canvas) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_set_custom_canvas)(const uint64_t /*godot::Control _canvas*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_set_custom_canvas, _canvas ? _canvas->get_instance_id() : 0);
#endif
}

static godot::Control * get_custom_canvas() {
	static const uint64_t (*DebugDraw2D_get_custom_canvas)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_OBJECT(DebugDraw2D_get_custom_canvas, godot::Control, {});
}

/**
 * Returns the DebugDraw2DStats instance with the current statistics.
 *
 * Some data can be delayed by 1 frame.
 */
static std::shared_ptr<DebugDraw2DStats> get_render_stats() {
	static void * (*DebugDraw2D_get_render_stats)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw2D_get_render_stats, DebugDraw2DStats, nullptr);
}

/**
 * Clear all 2D objects
 */
static void clear_all() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_clear_all)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_clear_all);
#endif
}

/**
 * Begin a text group to which all of the following text from DebugDraw2D.set_text will be added
 *
 * @param group_title Group title and ID
 * @param group_priority Group priority based on which groups will be sorted from top to bottom.
 * @param group_color Main color of the group
 * @param show_title Whether to show the title
 * @param title_size Title font size
 * @param text_size Text font size
 */
static void begin_text_group_c(const char * group_title_string, const int &group_priority = 0, const godot::Color &group_color = godot::Color(0.96f, 0.96f, 0.96f, 1.0f), const bool &show_title = true, const int &title_size = -1, const int &text_size = -1) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_begin_text_group_c)(const char * /*group_title_string*/, int /*group_priority*/, godot::Color /*group_color*/, bool /*show_title*/, int /*title_size*/, int /*text_size*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_begin_text_group_c, group_title_string, group_priority, group_color, show_title, title_size, text_size);
#endif
}

/**
 * Begin a text group to which all of the following text from DebugDraw2D.set_text will be added
 *
 * @param group_title Group title and ID
 * @param group_priority Group priority based on which groups will be sorted from top to bottom.
 * @param group_color Main color of the group
 * @param show_title Whether to show the title
 * @param title_size Title font size
 * @param text_size Text font size
 */
static void begin_text_group(const godot::String &group_title, const int &group_priority = 0, const godot::Color &group_color = godot::Color(0.96f, 0.96f, 0.96f, 1.0f), const bool &show_title = true, const int &title_size = -1, const int &text_size = -1) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	begin_text_group_c(group_title.utf8().ptr(), group_priority, group_color, show_title, title_size, text_size);
#endif
}

/**
 * Ends the text group. Should be called after DebugDraw2D.begin_text_group.
 *
 * If you need to create multiple groups, just call DebugDraw2D.begin_text_group again and this function at the end.
 */
static void end_text_group() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_end_text_group)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_end_text_group);
#endif
}

/**
 * Add or update text in an overlay
 *
 * @param key Left value if 'value' is set, otherwise the entire string is 'key'
 * @param value Value of field
 * @param priority Priority of this line. Lower value is higher position
 * @param color_of_value Value color
 * @param duration Expiration time
 */
static void set_text_c(const char * key_string, const char * value_string = "", const int &priority = 0, const godot::Color &color_of_value = godot::Color(0, 0, 0, 0), const real_t &duration = -1) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_set_text_c)(const char * /*key_string*/, const char * /*value_string*/, int /*priority*/, godot::Color /*color_of_value*/, real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_set_text_c, key_string, value_string, priority, color_of_value, duration);
#endif
}

/**
 * Add or update text in an overlay
 *
 * @param key Left value if 'value' is set, otherwise the entire string is 'key'
 * @param value Value of field
 * @param priority Priority of this line. Lower value is higher position
 * @param color_of_value Value color
 * @param duration Expiration time
 */
static void set_text(const godot::String &key, const godot::String &value = "", const int &priority = 0, const godot::Color &color_of_value = godot::Color(0, 0, 0, 0), const real_t &duration = -1) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	set_text_c(key.utf8().ptr(), value.utf8().ptr(), priority, color_of_value, duration);
#endif
}

/**
 * Clear all text
 */
static void clear_texts() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw2D_clear_texts)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw2D_clear_texts);
#endif
}

} // namespace DebugDraw2D

/**
 * @brief
 * You can get basic statistics about 2D rendering from this class.
 *
 * All names try to reflect what they mean.
 *
 * To get an instance of this class with current statistics, use DebugDraw2D.get_render_stats.
 */
class DebugDraw2DStats {
private:
	void *inst_ptr;

public:
	DebugDraw2DStats(void *inst_ptr) :
			inst_ptr(inst_ptr) {}

	DebugDraw2DStats(bool instantiate = true) :
			inst_ptr(instantiate ? create() : create_nullptr()) {}

	~DebugDraw2DStats() { destroy(inst_ptr); }

	operator void *() const { return inst_ptr; }

	int64_t get_overlay_text_groups() {
		static int64_t (*DebugDraw2DStats_get_overlay_text_groups)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DStats_get_overlay_text_groups, {}, inst_ptr);
	}

	void set_overlay_text_groups(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DStats_set_overlay_text_groups)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DStats_set_overlay_text_groups, inst_ptr, val);
#endif
	}

	int64_t get_overlay_text_lines() {
		static int64_t (*DebugDraw2DStats_get_overlay_text_lines)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DStats_get_overlay_text_lines, {}, inst_ptr);
	}

	void set_overlay_text_lines(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw2DStats_set_overlay_text_lines)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DStats_set_overlay_text_lines, inst_ptr, val);
#endif
	}

private:
	static void * create() {
		static void * (*DebugDraw2DStats_create)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DStats_create, nullptr);
	}

	static void * create_nullptr() {
		static void * (*DebugDraw2DStats_create_nullptr)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw2DStats_create_nullptr, nullptr);
	}

	static void destroy(void * inst_ptr) {
		static void (*DebugDraw2DStats_destroy)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw2DStats_destroy, inst_ptr);
	}

}; // class DebugDraw2DStats

/**
 * @brief
 * This is a class for storing part of the DebugDraw3D configuration.
 *
 * You can use DebugDraw3D.get_config to get the current instance of the configuration.
 */
class DebugDraw3DConfig {
public:
	enum CullingMode : uint32_t {
		FRUSTUM_DISABLED = 0,
		FRUSTUM_ROUGH = 1,
		FRUSTUM_PRECISE = 2,
	};

private:
	void *inst_ptr;

public:
	DebugDraw3DConfig(void *inst_ptr) :
			inst_ptr(inst_ptr) {}

	DebugDraw3DConfig(bool instantiate = true) :
			inst_ptr(instantiate ? create() : create_nullptr()) {}

	~DebugDraw3DConfig() { destroy(inst_ptr); }

	operator void *() const { return inst_ptr; }

	/**
	 * Set whether debug 3D graphics rendering is frozen.
	 * This means that previously created geometry will not be updated until set to false or until DebugDraw3D.clear_all is called.
	 */
	void set_freeze_3d_render(const bool &_state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_freeze_3d_render)(void * /*inst_ptr*/, const bool /*_state*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_freeze_3d_render, inst_ptr, _state);
#endif
	}

	bool is_freeze_3d_render() {
		static bool (*DebugDraw3DConfig_is_freeze_3d_render)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_is_freeze_3d_render, {}, inst_ptr);
	}

	/**
	 * Set whether the boundaries of instances are displayed.
	 * Based on these boundaries, instances are culled if set_use_frustum_culling is activated.
	 */
	void set_visible_instance_bounds(const bool &_state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_visible_instance_bounds)(void * /*inst_ptr*/, const bool /*_state*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_visible_instance_bounds, inst_ptr, _state);
#endif
	}

	bool is_visible_instance_bounds() {
		static bool (*DebugDraw3DConfig_is_visible_instance_bounds)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_is_visible_instance_bounds, {}, inst_ptr);
	}

	/**
	 * @deprecated
	 * Set whether frustum culling is used.
	 * This is a wrapper over DebugDraw3DConfig.set_frustum_culling_mode and exists for compatibility with older versions.
	 *
	 * @note
	 * Enabling or disabling this option does not affect the rough culling based on the camera's AABB of frustum.
	 * This option enables more accurate culling based on the camera's frustum planes.
	 */
	void set_use_frustum_culling(const bool &_state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_use_frustum_culling)(void * /*inst_ptr*/, const bool /*_state*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_use_frustum_culling, inst_ptr, _state);
#endif
	}

	bool is_use_frustum_culling() {
		static bool (*DebugDraw3DConfig_is_use_frustum_culling)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_is_use_frustum_culling, {}, inst_ptr);
	}

	/**
	 * Set frustum culling mode.
	 */
	void set_frustum_culling_mode(const DebugDraw3DConfig::CullingMode &_mode) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_frustum_culling_mode)(void * /*inst_ptr*/, uint32_t /*DebugDraw3DConfig::CullingMode _mode*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_frustum_culling_mode, inst_ptr, static_cast<uint32_t>(_mode));
#endif
	}

	DebugDraw3DConfig::CullingMode get_frustum_culling_mode() {
		static uint32_t /*DebugDraw3DConfig::CullingMode*/ (*DebugDraw3DConfig_get_frustum_culling_mode)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET_CAST(DebugDraw3DConfig_get_frustum_culling_mode, DebugDraw3DConfig::CullingMode, {}, inst_ptr);
	}

	/**
	 * Change the distance between the Far and Near Planes of the Viewport's Camera3D.
	 */
	void set_frustum_length_scale(const real_t &_distance) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_frustum_length_scale)(void * /*inst_ptr*/, const real_t /*_distance*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_frustum_length_scale, inst_ptr, _distance);
#endif
	}

	real_t get_frustum_length_scale() {
		static real_t (*DebugDraw3DConfig_get_frustum_length_scale)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_get_frustum_length_scale, {}, inst_ptr);
	}

	/**
	 * Set the forced use of the scene camera instead of the editor camera.
	 */
	void set_force_use_camera_from_scene(const bool &_state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_force_use_camera_from_scene)(void * /*inst_ptr*/, const bool /*_state*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_force_use_camera_from_scene, inst_ptr, _state);
#endif
	}

	bool is_force_use_camera_from_scene() {
		static bool (*DebugDraw3DConfig_is_force_use_camera_from_scene)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_is_force_use_camera_from_scene, {}, inst_ptr);
	}

	/**
	 * Set the visibility layer on which the 3D geometry will be drawn.
	 * Similar to using VisualInstance3D.layers.
	 */
	void set_geometry_render_layers(const int32_t &_layers) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_geometry_render_layers)(void * /*inst_ptr*/, const int32_t /*_layers*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_geometry_render_layers, inst_ptr, _layers);
#endif
	}

	int32_t get_geometry_render_layers() {
		static int32_t (*DebugDraw3DConfig_get_geometry_render_layers)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_get_geometry_render_layers, {}, inst_ptr);
	}

	/**
	 * Set the default color for the collision point of DebugDraw3D.draw_line_hit.
	 */
	void set_line_hit_color(const godot::Color &_new_color) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_line_hit_color)(void * /*inst_ptr*/, const godot::Color /*_new_color*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_line_hit_color, inst_ptr, _new_color);
#endif
	}

	godot::Color get_line_hit_color() {
		static godot::Color (*DebugDraw3DConfig_get_line_hit_color)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_get_line_hit_color, {}, inst_ptr);
	}

	/**
	 * Set the default color for the line after the collision point of DebugDraw3D.draw_line_hit.
	 */
	void set_line_after_hit_color(const godot::Color &_new_color) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DConfig_set_line_after_hit_color)(void * /*inst_ptr*/, const godot::Color /*_new_color*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_set_line_after_hit_color, inst_ptr, _new_color);
#endif
	}

	godot::Color get_line_after_hit_color() {
		static godot::Color (*DebugDraw3DConfig_get_line_after_hit_color)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_get_line_after_hit_color, {}, inst_ptr);
	}

private:
	static void * create() {
		static void * (*DebugDraw3DConfig_create)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_create, nullptr);
	}

	static void * create_nullptr() {
		static void * (*DebugDraw3DConfig_create_nullptr)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DConfig_create_nullptr, nullptr);
	}

	static void destroy(void * inst_ptr) {
		static void (*DebugDraw3DConfig_destroy)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DConfig_destroy, inst_ptr);
	}

}; // class DebugDraw3DConfig

/**
 * @brief
 * This class is used to override scope parameters for DebugDraw3D.
 *
 * `Scope` means that these overridden parameters will affect the drawn geometry until it exits the current scope.
 *
 * To create it, use DebugDraw3D.new_scoped_config.
 * Immediately after creation, you can change the values and save the reference in a variable.
 *
 * @warning
 * But the main thing is not to save it outside the method or in other objects.
 * After leaving the scope, this object should be deleted.
 *
 * ---
 * @warning
 * Also, you can't use scope config between `await`s unless this object is freed before `await`.
 * So, narrow the scope if you want to use `await` and DebugDraw3DScopeConfig in the same method.
 * Or set the value of the variable to `null` so that the object is cleared due to lack of references.
 * ```python
 * # Bad example
 * var _s = DebugDraw3D.new_scoped_config().set_thickness(0.3)
 * DebugDraw3D.draw_box(Vector3.ZERO, Quaternion.IDENTITY, Vector3.ONE)
 * await get_tree().process_frame
 * # your code...
 *
 * # Good example
 * if true:
 * 	var _s = DebugDraw3D.new_scoped_config().set_thickness(0.3)
 * 	DebugDraw3D.draw_box(Vector3.ZERO, Quaternion.IDENTITY, Vector3.ONE)
 * await get_tree().process_frame
 * # your code...
 * ```
 *
 * ### Examples:
 * ```python
 * var _s = DebugDraw3D.new_scoped_config().set_thickness(0.025).set_center_brightness(0.7)
 * DebugDraw3D.draw_grid_xf(%Grid.global_transform, Vector2i(10,10), Color.LIGHT_GRAY)
 * ```
 *
 * ```cs
 * using (var s = DebugDraw3D.NewScopedConfig().SetThickness(0))
 *     DebugDraw3D.DrawCameraFrustum(dCamera, Colors.DarkOrange);
 * ```
 */
class DebugDraw3DScopeConfig : public std::enable_shared_from_this<DebugDraw3DScopeConfig> {
private:
	void *inst_ptr;

public:
	DebugDraw3DScopeConfig(void *inst_ptr) :
			inst_ptr(inst_ptr) {}

	DebugDraw3DScopeConfig(bool instantiate = true) :
			inst_ptr(instantiate ? create() : create_nullptr()) {}

	~DebugDraw3DScopeConfig() { destroy(inst_ptr); }

	operator void *() const { return inst_ptr; }

	/**
	 * Set the thickness of the volumetric lines. If the value is 0, the standard wireframe rendering will be used.
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_thickness(const real_t &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_thickness_selfreturn)(void * /*inst_ptr*/, const real_t /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_thickness_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	real_t get_thickness() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static real_t (*DebugDraw3DScopeConfig_get_thickness)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_thickness, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the brightness of the central part of the volumetric lines.
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_center_brightness(const real_t &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_center_brightness_selfreturn)(void * /*inst_ptr*/, const real_t /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_center_brightness_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	real_t get_center_brightness() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static real_t (*DebugDraw3DScopeConfig_get_center_brightness)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_center_brightness, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the mesh density of the sphere
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_hd_sphere(const bool &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_hd_sphere_selfreturn)(void * /*inst_ptr*/, const bool /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_hd_sphere_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	bool is_hd_sphere() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static bool (*DebugDraw3DScopeConfig_is_hd_sphere)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_is_hd_sphere, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the size of the `Plane` in DebugDraw3D.draw_plane. If set to `INF`, the `Far` parameter of the current camera will be used.
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_plane_size(const real_t &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_plane_size_selfreturn)(void * /*inst_ptr*/, const real_t /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_plane_size_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	real_t get_plane_size() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static real_t (*DebugDraw3DScopeConfig_get_plane_size)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_plane_size, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the base/local `transform` relative to which the shapes will be drawn.
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_transform(const godot::Transform3D &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_transform_selfreturn)(void * /*inst_ptr*/, const godot::Transform3D /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_transform_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	godot::Transform3D get_transform() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static godot::Transform3D (*DebugDraw3DScopeConfig_get_transform)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_transform, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the `outline` color in DebugDraw3D.draw_text.
	 *
	 * [THERE WAS AN IMAGE]
	 *
	 * @warning
	 * Frequent unsystematic changes to this property can lead to significant performance degradation.
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_text_outline_color(const godot::Color &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_text_outline_color_selfreturn)(void * /*inst_ptr*/, const godot::Color /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_text_outline_color_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	godot::Color get_text_outline_color() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static godot::Color (*DebugDraw3DScopeConfig_get_text_outline_color)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_text_outline_color, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the size of the `outline` in DebugDraw3D.draw_text.
	 *
	 * [THERE WAS AN IMAGE]
	 *
	 * @warning
	 * Frequent unsystematic changes to this property can lead to significant performance degradation.
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_text_outline_size(const int32_t &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_text_outline_size_selfreturn)(void * /*inst_ptr*/, const int32_t /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_text_outline_size_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	int32_t get_text_outline_size() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static int32_t (*DebugDraw3DScopeConfig_get_text_outline_size)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_text_outline_size, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Makes the text in DebugDraw3D.draw_text the same size regardless of distance.
	 *
	 * [THERE WAS AN IMAGE]
	 *
	 * @warning
	 * Frequent unsystematic changes to this property can lead to significant performance degradation.
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_text_fixed_size(const bool &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn)(void * /*inst_ptr*/, const bool /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	bool get_text_fixed_size() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static bool (*DebugDraw3DScopeConfig_get_text_fixed_size)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_get_text_fixed_size, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set the font of the text in DebugDraw3D.draw_text.
	 *
	 * [THERE WAS AN IMAGE]
	 *
	 * @warning
	 * Frequent unsystematic changes to this property can lead to significant performance degradation.
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_text_font(const godot::Ref<godot::Font> &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_text_font_selfreturn)(void * /*inst_ptr*/, const uint64_t /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_text_font_selfreturn, inst_ptr, _value.is_valid() ? _value->get_instance_id() : 0);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	godot::Ref<godot::Font> get_text_font() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static const uint64_t (*DebugDraw3DScopeConfig_get_text_font)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_REF(DebugDraw3DScopeConfig_get_text_font, godot::Font, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set which Viewport will be used to get World3D.
	 *
	 * If the World3D of this Viewport has not been used before,
	 * then the owner of this World3D will be found in the current branch of the tree,
	 * and special observer nodes will be added to it.
	 *
	 * @note
	 * Objects created for a specific Viewport will use only one camera related to that Viewport for culling.
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_viewport(const godot::Viewport * _value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_viewport_selfreturn)(void * /*inst_ptr*/, const uint64_t /*godot::Viewport _value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_viewport_selfreturn, inst_ptr, _value ? _value->get_instance_id() : 0);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	godot::Viewport * get_viewport() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static const uint64_t (*DebugDraw3DScopeConfig_get_viewport)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_OBJECT(DebugDraw3DScopeConfig_get_viewport, godot::Viewport, {}, inst_ptr);
#else
		return {};
#endif
	}

	/**
	 * Set whether the `depth_test_disabled` flag is added or not in the shaders of the debug shapes.
	 *
	 * @note
	 * It may cause artifacts when drawing volumetric objects.
	 *
	 * [THERE WAS AN IMAGE]
	 */
	std::shared_ptr<DebugDraw3DScopeConfig> set_no_depth_test(const bool &_value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DScopeConfig_set_no_depth_test_selfreturn)(void * /*inst_ptr*/, const bool /*_value*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_SELFRET(DebugDraw3DScopeConfig_set_no_depth_test_selfreturn, inst_ptr, _value);
		return shared_from_this();
#else
		return shared_from_this();
#endif
	}

	bool is_no_depth_test() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static bool (*DebugDraw3DScopeConfig_is_no_depth_test)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_is_no_depth_test, {}, inst_ptr);
#else
		return {};
#endif
	}

private:
	static void * create() {
		static void * (*DebugDraw3DScopeConfig_create)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_create, nullptr);
	}

	static void * create_nullptr() {
		static void * (*DebugDraw3DScopeConfig_create_nullptr)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DScopeConfig_create_nullptr, nullptr);
	}

	static void destroy(void * inst_ptr) {
		static void (*DebugDraw3DScopeConfig_destroy)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DScopeConfig_destroy, inst_ptr);
	}

}; // class DebugDraw3DScopeConfig

/**
 * @brief
 * Singleton class for calling debugging 3D methods.
 *
 * You can use the project settings `debug_draw_3d/settings/3d` for additional customization.
 *
 * For example, `add_bevel_to_volumetric_geometry` allows you to remove or add a bevel for volumetric lines.
 *
 * [THERE WAS AN IMAGE]
 *
 * `use_icosphere` and `use_icosphere_for_hd` allow you to change the sphere mesh.
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * Wireframe shapes and volumetric wireframes do not support translucency to avoid overlap issues and for better performance.
 * At this point, you can use translucency when drawing planes DebugDraw3D.draw_plane.
 *
 * ---
 * @note
 * Objects created in `_physics_process` are processed separately from those created in `_process`,
 * so they will be deleted only in the first physics tick after rendering.
 * This allows to display objects even if several frames passed between physics ticks.
 *
 * ---
 * @note
 * You can use this class anywhere, including in `_physics_process` and `_process` (and probably from other threads).
 * It is worth mentioning that physics ticks may not be called every frame or may be called several times in one frame.
 * So if you want to avoid multiple identical `draw_` calls, you can call `draw_` methods in `_process` or use such a check:
 * ```python
 * var physics_tick_processed := false
 * func _process(delta: float) -> void:
 * 	# Reset after rendering frame
 * 	physics_tick_processed = false
 * 	# some logic
 *
 * func _physics_process(delta: float) -> void:
 * 	if not physics_tick_processed:
 * 		physics_tick_processed = true
 * 		# some DD3D logic
 * ```
 *
 * ---
 * @note
 * Due to the way Godot registers this addon, it is not possible to use the `draw_` methods
 * in the first few frames immediately after the project is launched.
 */
namespace DebugDraw3D {
enum PointType : uint32_t {
	POINT_TYPE_SQUARE = 0,
	POINT_TYPE_SPHERE = 1,
};

/**
 * Create a new DebugDraw3DScopeConfig instance and register it.
 *
 * This class allows you to override some parameters within scope for the following `draw_*` calls.
 *
 * Store this instance in a local variable inside the method.
 */
static std::shared_ptr<DebugDraw3DScopeConfig> new_scoped_config() {
	static void * (*DebugDraw3D_new_scoped_config)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw3D_new_scoped_config, DebugDraw3DScopeConfig, nullptr);
}

/**
 * Returns the default scope settings that will be applied at the start of each new frame.
 *
 * Default values can be overridden in the project settings `debug_draw_3d/settings/3d/volumetric_defaults`.
 *
 * @note
 * When used in a managed language, this is not mandatory, but it is recommended to finish the `scoped_config()` configuration with a dispose.
 * This will reduce the number of objects awaiting removal by the garbage collector.
 * ```cs
 * DebugDraw3D.ScopedConfig().SetThickness(debug_thickness).Dispose();
 * ```
 */
static std::shared_ptr<DebugDraw3DScopeConfig> scoped_config() {
	static void * (*DebugDraw3D_scoped_config)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw3D_scoped_config, DebugDraw3DScopeConfig, nullptr);
}

/**
 * Set the configuration global for everything in DebugDraw3D.
 */
static void set_config(const std::shared_ptr<DebugDraw3DConfig> &cfg) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_set_config)(void * /*cfg*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_set_config, *cfg);
#endif
}

/**
 * Get the DebugDraw3DConfig.
 */
static std::shared_ptr<DebugDraw3DConfig> get_config() {
	static void * (*DebugDraw3D_get_config)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw3D_get_config, DebugDraw3DConfig, nullptr);
}

/**
 * Set whether debug drawing works or not.
 */
static void set_debug_enabled(const bool &state) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_set_debug_enabled)(const bool /*state*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_set_debug_enabled, state);
#endif
}

static bool is_debug_enabled() {
	static bool (*DebugDraw3D_is_debug_enabled)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3D_is_debug_enabled, {});
}

/**
 * Returns an instance of DebugDraw3DStats with the current statistics.
 *
 * Some data can be delayed by 1 frame.
 */
static std::shared_ptr<DebugDraw3DStats> get_render_stats() {
	static void * (*DebugDraw3D_get_render_stats)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw3D_get_render_stats, DebugDraw3DStats, nullptr);
}

/**
 * Returns an instance of DebugDraw3DStats with the current statistics for the World3D of the Viewport.
 *
 * Some data can be delayed by 1 frame.
 */
static std::shared_ptr<DebugDraw3DStats> get_render_stats_for_world(const godot::Viewport * viewport) {
	static void * (*DebugDraw3D_get_render_stats_for_world)(const uint64_t /*godot::Viewport viewport*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED(DebugDraw3D_get_render_stats_for_world, DebugDraw3DStats, nullptr, viewport ? viewport->get_instance_id() : 0);
}

/**
 * Regenerate meshes.
 *
 * Can be useful if you want to change some project settings and not restart the project.
 */
static void regenerate_geometry_meshes() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_regenerate_geometry_meshes)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_regenerate_geometry_meshes);
#endif
}

/**
 * Clear all 3D geometry
 */
static void clear_all() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_clear_all)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_clear_all);
#endif
}

/**
 * Draw a sphere
 *
 * [THERE WAS AN IMAGE]
 *
 * @param position Center of the sphere
 * @param radius Sphere radius
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_sphere(const godot::Vector3 &position, const real_t &radius = 0.5f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_sphere)(const godot::Vector3 /*position*/, const real_t /*radius*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_sphere, position, radius, color, duration);
#endif
}

/**
 * Draw a sphere with a radius of 0.5
 *
 * [THERE WAS AN IMAGE]
 *
 * @param transform Sphere transform
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_sphere_xf(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_sphere_xf)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_sphere_xf, transform, color, duration);
#endif
}

/**
 * Draw a vertical capsule
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * A capsule will not be displayed if the height or radius is approximately equal to or less than zero.
 *
 * ---
 * @note
 * If you need to apply additional transformations, you can use DebugDraw3DScopeConfig.set_transform.
 *
 * @param position Capsule position
 * @param rotation Capsule rotation
 * @param radius Capsule radius
 * @param height Capsule height including caps. Based on this value, the actual radius of the capsule will be calculated.
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_capsule(const godot::Vector3 &position, const godot::Quaternion &rotation, const real_t &radius, const real_t &height, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_capsule)(const godot::Vector3 /*position*/, const DD3DShared::CQuaternion /*rotation*/, const real_t /*radius*/, const real_t /*height*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_capsule, position, rotation, radius, height, color, duration);
#endif
}

/**
 * Draw a capsule between points A and B with the desired radius.
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * A capsule will not be displayed if the distance between points A and B or the radius is approximately equal to or less than zero.
 *
 * @param a First pole of the capsule
 * @param b Second pole of the capsule
 * @param radius Capsule radius
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_capsule_ab(const godot::Vector3 &a, const godot::Vector3 &b, const real_t &radius = 0.5f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_capsule_ab)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const real_t /*radius*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_capsule_ab, a, b, radius, color, duration);
#endif
}

/**
 * Draw a vertical cylinder with radius 1.0 (x, z) and height 1.0 (y)
 *
 * [THERE WAS AN IMAGE]
 *
 * @param transform Cylinder transform
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_cylinder(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_cylinder)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_cylinder, transform, color, duration);
#endif
}

/**
 * Draw a cylinder between points A and B with a certain radius.
 *
 * @note
 * A cylinder will not be displayed if the distance between points A and B is approximately zero.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param a Bottom point of the Cylinder
 * @param b Top point of the Cylinder
 * @param radius Cylinder radius
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_cylinder_ab(const godot::Vector3 &a, const godot::Vector3 &b, const real_t &radius = 0.5f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_cylinder_ab)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const real_t /*radius*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_cylinder_ab, a, b, radius, color, duration);
#endif
}

/**
 * Draw a box
 *
 * [THERE WAS AN IMAGE]
 *
 * [THERE WAS AN IMAGE]
 *
 * @param position Position of the Box
 * @param rotation Rotation of the box
 * @param size Size of the Box
 * @param color Primary color
 * @param is_box_centered Set where the center of the box will be. In the center or in the bottom corner
 * @param duration The duration of how long the object will be visible
 */
static void draw_box(const godot::Vector3 &position, const godot::Quaternion &rotation, const godot::Vector3 &size, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_box_centered = false, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_box)(const godot::Vector3 /*position*/, const DD3DShared::CQuaternion /*rotation*/, const godot::Vector3 /*size*/, const godot::Color /*color*/, const bool /*is_box_centered*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_box, position, rotation, size, color, is_box_centered, duration);
#endif
}

/**
 * Draw a box between points A and B by rotating and scaling based on the up vector
 *
 * [THERE WAS AN IMAGE]
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * A box will not be displayed if its dimensions are close to zero or if the up vector is approximately zero.
 *
 * @param a Start position
 * @param b End position
 * @param up Vertical vector by which the box will be aligned
 * @param color Primary color
 * @param is_ab_diagonal Set uses the diagonal between the corners or the diagonal between the centers of two edges
 * @param duration The duration of how long the object will be visible
 */
static void draw_box_ab(const godot::Vector3 &a, const godot::Vector3 &b, const godot::Vector3 &up, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_ab_diagonal = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_box_ab)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const godot::Vector3 /*up*/, const godot::Color /*color*/, const bool /*is_ab_diagonal*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_box_ab, a, b, up, color, is_ab_diagonal, duration);
#endif
}

/**
 * Draw a box as in DebugDraw3D.draw_box
 *
 * @param transform Box transform
 * @param color Primary color
 * @param is_box_centered Set where the center of the box will be. In the center or in the bottom corner
 * @param duration The duration of how long the object will be visible
 */
static void draw_box_xf(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_box_centered = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_box_xf)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const bool /*is_box_centered*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_box_xf, transform, color, is_box_centered, duration);
#endif
}

/**
 * Draw a box as in DebugDraw3D.draw_box, but based on the AABB
 *
 * @param aabb AABB
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_aabb(const godot::AABB &aabb, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_aabb)(const godot::AABB /*aabb*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_aabb, aabb, color, duration);
#endif
}

/**
 * Draw the box as in DebugDraw3D.draw_aabb, but AABB is defined by the diagonal AB
 *
 * @param a Start position
 * @param b End position
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_aabb_ab(const godot::Vector3 &a, const godot::Vector3 &b, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_aabb_ab)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_aabb_ab, a, b, color, duration);
#endif
}

/**
 * Draw line separated by hit point (billboard square) or not separated if `is_hit = false`.
 *
 * Some of the default settings can be overridden in DebugDraw3DConfig.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param start Start point
 * @param end End point
 * @param hit Hit point
 * @param is_hit Whether to draw the collision point
 * @param hit_size Size of the hit point
 * @param hit_color Color of the hit point and line before hit
 * @param after_hit_color Color of line after hit position
 * @param duration The duration of how long the object will be visible
 */
static void draw_line_hit(const godot::Vector3 &start, const godot::Vector3 &end, const godot::Vector3 &hit, const bool &is_hit, const real_t &hit_size = 0.25f, const godot::Color &hit_color = godot::Color(0, 0, 0, 0), const godot::Color &after_hit_color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_line_hit)(const godot::Vector3 /*start*/, const godot::Vector3 /*end*/, const godot::Vector3 /*hit*/, const bool /*is_hit*/, const real_t /*hit_size*/, const godot::Color /*hit_color*/, const godot::Color /*after_hit_color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_line_hit, start, end, hit, is_hit, hit_size, hit_color, after_hit_color, duration);
#endif
}

/**
 * Draw line separated by hit point.
 *
 * Similar to DebugDraw3D.draw_line_hit, but instead of a hit point, an offset from the start point is used.
 *
 * Some of the default settings can be overridden in DebugDraw3DConfig.
 *
 * @param start Start point
 * @param end End point
 * @param is_hit Whether to draw the collision point
 * @param unit_offset_of_hit Unit offset on the line where the collision occurs
 * @param hit_size Size of the hit point
 * @param hit_color Color of the hit point and line before hit
 * @param after_hit_color Color of line after hit position
 * @param duration The duration of how long the object will be visible
 */
static void draw_line_hit_offset(const godot::Vector3 &start, const godot::Vector3 &end, const bool &is_hit, const real_t &unit_offset_of_hit = 0.5f, const real_t &hit_size = 0.25f, const godot::Color &hit_color = godot::Color(0, 0, 0, 0), const godot::Color &after_hit_color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_line_hit_offset)(const godot::Vector3 /*start*/, const godot::Vector3 /*end*/, const bool /*is_hit*/, const real_t /*unit_offset_of_hit*/, const real_t /*hit_size*/, const godot::Color /*hit_color*/, const godot::Color /*after_hit_color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_line_hit_offset, start, end, is_hit, unit_offset_of_hit, hit_size, hit_color, after_hit_color, duration);
#endif
}

/**
 * Draw a single line
 *
 * [THERE WAS AN IMAGE]
 *
 * @param a Start point
 * @param b End point
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_line(const godot::Vector3 &a, const godot::Vector3 &b, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_line)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_line, a, b, color, duration);
#endif
}

/**
 * Draw a ray.
 *
 * Same as DebugDraw3D.draw_line, but uses origin, direction and length instead of A and B.
 *
 * @param origin Origin
 * @param direction Direction
 * @param length Length
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_ray(const godot::Vector3 &origin, const godot::Vector3 &direction, const real_t &length, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_ray)(const godot::Vector3 /*origin*/, const godot::Vector3 /*direction*/, const real_t /*length*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_ray, origin, direction, length, color, duration);
#endif
}

/**
 * Draw an array of lines. Each line is two points, so the array must be of even size.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param lines An array of points of lines. 1 line = 2 vectors3. The array size must be even.
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_lines_c(const godot::Vector3 * lines_data, const uint64_t &lines_size, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_lines_c)(const godot::Vector3 * /*lines_data*/, const uint64_t /*lines_size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_lines_c, lines_data, lines_size, color, duration);
#endif
}

/**
 * Draw an array of lines. Each line is two points, so the array must be of even size.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param lines An array of points of lines. 1 line = 2 vectors3. The array size must be even.
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_lines(const godot::PackedVector3Array &lines, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_lines_c(lines.ptr(), lines.size(), color, duration);
#endif
}

/**
 * Draw an array of lines.
 *
 * Unlike DebugDraw3D.draw_lines, here lines are drawn between each point in the array.
 *
 * The array can be of any size.
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_line_path_c(const godot::Vector3 * path_data, const uint64_t &path_size, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_line_path_c)(const godot::Vector3 * /*path_data*/, const uint64_t /*path_size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_line_path_c, path_data, path_size, color, duration);
#endif
}

/**
 * Draw an array of lines.
 *
 * Unlike DebugDraw3D.draw_lines, here lines are drawn between each point in the array.
 *
 * The array can be of any size.
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_line_path(const godot::PackedVector3Array &path, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_line_path_c(path.ptr(), path.size(), color, duration);
#endif
}

/**
 * Draw the arrowhead
 *
 * @param transform godot::Transform3D of the Arrowhead
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_arrowhead(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_arrowhead)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_arrowhead, transform, color, duration);
#endif
}

/**
 * Draw line with arrowhead
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * An arrow will not be displayed if the distance between points a and b is approximately zero.
 *
 * @param a Start point
 * @param b End point
 * @param color Primary color
 * @param arrow_size Size of the arrow
 * @param is_absolute_size Is `arrow_size` absolute or relative to the length of the string?
 * @param duration The duration of how long the object will be visible
 */
static void draw_arrow(const godot::Vector3 &a, const godot::Vector3 &b, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &arrow_size = 0.5f, const bool &is_absolute_size = false, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_arrow)(const godot::Vector3 /*a*/, const godot::Vector3 /*b*/, const godot::Color /*color*/, const real_t /*arrow_size*/, const bool /*is_absolute_size*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_arrow, a, b, color, arrow_size, is_absolute_size, duration);
#endif
}

/**
 * Same as DebugDraw3D.draw_arrow, but uses origin, direction and length instead of A and B.
 *
 * @param origin Origin
 * @param direction Direction
 * @param length Length
 * @param color Primary color
 * @param arrow_size Size of the arrow
 * @param is_absolute_size Is `arrow_size` absolute or relative to the line length?
 * @param duration The duration of how long the object will be visible
 */
static void draw_arrow_ray(const godot::Vector3 &origin, const godot::Vector3 &direction, const real_t &length, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &arrow_size = 0.5f, const bool &is_absolute_size = false, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_arrow_ray)(const godot::Vector3 /*origin*/, const godot::Vector3 /*direction*/, const real_t /*length*/, const godot::Color /*color*/, const real_t /*arrow_size*/, const bool /*is_absolute_size*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_arrow_ray, origin, direction, length, color, arrow_size, is_absolute_size, duration);
#endif
}

/**
 * Draw a sequence of points connected by lines with arrows like DebugDraw3D.draw_line_path.
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param color Primary color
 * @param arrow_size Size of the arrow
 * @param is_absolute_size Is the `arrow_size` absolute or relative to the length of the line?
 * @param duration The duration of how long the object will be visible
 */
static void draw_arrow_path_c(const godot::Vector3 * path_data, const uint64_t &path_size, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &arrow_size = 0.75f, const bool &is_absolute_size = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_arrow_path_c)(const godot::Vector3 * /*path_data*/, const uint64_t /*path_size*/, const godot::Color /*color*/, const real_t /*arrow_size*/, const bool /*is_absolute_size*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_arrow_path_c, path_data, path_size, color, arrow_size, is_absolute_size, duration);
#endif
}

/**
 * Draw a sequence of points connected by lines with arrows like DebugDraw3D.draw_line_path.
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param color Primary color
 * @param arrow_size Size of the arrow
 * @param is_absolute_size Is the `arrow_size` absolute or relative to the length of the line?
 * @param duration The duration of how long the object will be visible
 */
static void draw_arrow_path(const godot::PackedVector3Array &path, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &arrow_size = 0.75f, const bool &is_absolute_size = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_arrow_path_c(path.ptr(), path.size(), color, arrow_size, is_absolute_size, duration);
#endif
}

/**
 * Draw a sequence of points connected by lines using billboard squares or spheres like DebugDraw3D.draw_line_path.
 *
 * [THERE WAS AN IMAGE]
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square or DebugDraw3D.draw_sphere will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param type Type of points
 * @param points_color Color of points
 * @param lines_color Color of lines
 * @param size Size of squares
 * @param duration The duration of how long the object will be visible
 */
static void draw_point_path_c(const godot::Vector3 * path_data, const uint64_t &path_size, const DebugDraw3D::PointType &type = PointType::POINT_TYPE_SQUARE, const real_t &size = 0.25f, const godot::Color &points_color = godot::Color(0, 0, 0, 0), const godot::Color &lines_color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_point_path_c)(const godot::Vector3 * /*path_data*/, const uint64_t /*path_size*/, uint32_t /*DebugDraw3D::PointType type*/, const real_t /*size*/, const godot::Color /*points_color*/, const godot::Color /*lines_color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_point_path_c, path_data, path_size, static_cast<uint32_t>(type), size, points_color, lines_color, duration);
#endif
}

/**
 * Draw a sequence of points connected by lines using billboard squares or spheres like DebugDraw3D.draw_line_path.
 *
 * [THERE WAS AN IMAGE]
 *
 * [THERE WAS AN IMAGE]
 *
 * @note
 * If the path size is equal to 1, then DebugDraw3D.draw_square or DebugDraw3D.draw_sphere will be used instead of drawing a line.
 *
 * @param path Sequence of points
 * @param type Type of points
 * @param points_color Color of points
 * @param lines_color Color of lines
 * @param size Size of squares
 * @param duration The duration of how long the object will be visible
 */
static void draw_point_path(const godot::PackedVector3Array &path, const DebugDraw3D::PointType &type = PointType::POINT_TYPE_SQUARE, const real_t &size = 0.25f, const godot::Color &points_color = godot::Color(0, 0, 0, 0), const godot::Color &lines_color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_point_path_c(path.ptr(), path.size(), type, size, points_color, lines_color, duration);
#endif
}

/**
 * Draw a sequence of points using billboard squares or spheres.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param points Sequence of points
 * @param type Type of points
 * @param size Size of squares
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_points_c(const godot::Vector3 * points_data, const uint64_t &points_size, const DebugDraw3D::PointType &type = DebugDraw3D::PointType::POINT_TYPE_SQUARE, const real_t &size = 0.25f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_points_c)(const godot::Vector3 * /*points_data*/, const uint64_t /*points_size*/, uint32_t /*DebugDraw3D::PointType type*/, const real_t /*size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_points_c, points_data, points_size, static_cast<uint32_t>(type), size, color, duration);
#endif
}

/**
 * Draw a sequence of points using billboard squares or spheres.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param points Sequence of points
 * @param type Type of points
 * @param size Size of squares
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_points(const godot::PackedVector3Array &points, const DebugDraw3D::PointType &type = DebugDraw3D::PointType::POINT_TYPE_SQUARE, const real_t &size = 0.25f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_points_c(points.ptr(), points.size(), type, size, color, duration);
#endif
}

/**
 * Draw a square that will always be turned towards the camera
 *
 * @param position Center position of square
 * @param size Square size
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_square(const godot::Vector3 &position, const real_t &size = 0.2f, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_square)(const godot::Vector3 /*position*/, const real_t /*size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_square, position, size, color, duration);
#endif
}

/**
 * Draws a plane of non-infinite size relative to the position of the current camera.
 *
 * The plane size is set based on the `Far` parameter of the current camera or with DebugDraw3DScopeConfig.set_plane_size.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param plane Plane data
 * @param color Primary color
 * @param anchor_point A point that is projected onto a Plane, and its projection is used as the center of the drawn plane
 * @param duration The duration of how long the object will be visible
 */
static void draw_plane(const godot::Plane &plane, const godot::Color &color = godot::Color(0, 0, 0, 0), const godot::Vector3 &anchor_point = godot::Vector3(INFINITY, INFINITY, INFINITY), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_plane)(const godot::Plane /*plane*/, const godot::Color /*color*/, const godot::Vector3 /*anchor_point*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_plane, plane, color, anchor_point, duration);
#endif
}

/**
 * Draw 3 intersecting lines with the given transformations
 *
 * [THERE WAS AN IMAGE]
 *
 * @param transform godot::Transform3D of lines
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_position(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_position)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_position, transform, color, duration);
#endif
}

/**
 * Draw 3 lines with the given transformations and arrows at the ends
 *
 * [THERE WAS AN IMAGE]
 *
 * [THERE WAS AN IMAGE]
 *
 * @param transform godot::Transform3D of lines
 * @param color Primary color
 * @param is_centered If `true`, then the lines will intersect in the center of the transform
 * @param duration The duration of how long the object will be visible
 */
static void draw_gizmo(const godot::Transform3D &transform, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_centered = false, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_gizmo)(const godot::Transform3D /*transform*/, const godot::Color /*color*/, const bool /*is_centered*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_gizmo, transform, color, is_centered, duration);
#endif
}

/**
 * Draw simple grid with given size and subdivision
 *
 * [THERE WAS AN IMAGE]
 *
 * @param origin Grid origin
 * @param x_size Direction and size of the X side. As an axis in the Basis.
 * @param y_size Direction and size of the Y side. As an axis in the Basis.
 * @param subdivision Number of cells for the X and Y axes
 * @param color Primary color
 * @param is_centered Draw lines relative to origin
 * @param duration The duration of how long the object will be visible
 */
static void draw_grid(const godot::Vector3 &origin, const godot::Vector3 &x_size, const godot::Vector3 &y_size, const godot::Vector2i &subdivision, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_centered = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_grid)(const godot::Vector3 /*origin*/, const godot::Vector3 /*x_size*/, const godot::Vector3 /*y_size*/, const godot::Vector2i /*subdivision*/, const godot::Color /*color*/, const bool /*is_centered*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_grid, origin, x_size, y_size, subdivision, color, is_centered, duration);
#endif
}

/**
 * Draw a simple grid with a given transform and subdivision.
 *
 * Like DebugDraw3D.draw_grid, but instead of origin, x_size and y_size, a single transform is used.
 *
 * @param transform godot::Transform3D of the Grid
 * @param p_subdivision Number of cells for the X and Y axes
 * @param color Primary color
 * @param is_centered Draw lines relative to origin
 * @param duration The duration of how long the object will be visible
 */
static void draw_grid_xf(const godot::Transform3D &transform, const godot::Vector2i &p_subdivision, const godot::Color &color = godot::Color(0, 0, 0, 0), const bool &is_centered = true, const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_grid_xf)(const godot::Transform3D /*transform*/, const godot::Vector2i /*p_subdivision*/, const godot::Color /*color*/, const bool /*is_centered*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_grid_xf, transform, p_subdivision, color, is_centered, duration);
#endif
}

/**
 * Draw camera frustum area.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param camera Camera node
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_camera_frustum(const godot::Camera3D * camera, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_camera_frustum)(const uint64_t /*godot::Camera3D camera*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_camera_frustum, camera ? camera->get_instance_id() : 0, color, duration);
#endif
}

/**
 * Draw the frustum area of the camera based on an array of 6 planes.
 *
 * @param camera_frustum Array of frustum planes
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_camera_frustum_planes_c(const godot::Plane * camera_frustum_data, const uint64_t &camera_frustum_size, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_camera_frustum_planes_c)(const godot::Plane * /*camera_frustum_data*/, const uint64_t /*camera_frustum_size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_camera_frustum_planes_c, camera_frustum_data, camera_frustum_size, color, duration);
#endif
}

/**
 * Draw text using Label3D.
 *
 * @note
 * Outline can be changed using DebugDraw3DScopeConfig.set_text_outline_color and DebugDraw3DScopeConfig.set_text_outline_size.
 * The font can be changed using DebugDraw3DScopeConfig.set_text_font.
 * The text can be made to stay the same size regardless of distance using DebugDraw3DScopeConfig.set_text_fixed_size.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param position Center position of Label
 * @param text Label's text
 * @param size Font size
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_text_c(const godot::Vector3 &position, const char * text_string, const int &size = 32, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDraw3D_draw_text_c)(const godot::Vector3 /*position*/, const char * /*text_string*/, const int /*size*/, const godot::Color /*color*/, const real_t /*duration*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDraw3D_draw_text_c, position, text_string, size, color, duration);
#endif
}

/**
 * Draw text using Label3D.
 *
 * @note
 * Outline can be changed using DebugDraw3DScopeConfig.set_text_outline_color and DebugDraw3DScopeConfig.set_text_outline_size.
 * The font can be changed using DebugDraw3DScopeConfig.set_text_font.
 * The text can be made to stay the same size regardless of distance using DebugDraw3DScopeConfig.set_text_fixed_size.
 *
 * [THERE WAS AN IMAGE]
 *
 * @param position Center position of Label
 * @param text Label's text
 * @param size Font size
 * @param color Primary color
 * @param duration The duration of how long the object will be visible
 */
static void draw_text(const godot::Vector3 &position, const godot::String &text, const int &size = 32, const godot::Color &color = godot::Color(0, 0, 0, 0), const real_t &duration = 0) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	draw_text_c(position, text.utf8().ptr(), size, color, duration);
#endif
}

} // namespace DebugDraw3D

/**
 * @brief
 * You can get statistics about 3D rendering from this class.
 *
 * All names try to reflect what they mean.
 *
 * To get an instance of this class with current statistics, use DebugDraw3D.get_render_stats.
 *
 * `instances` lets you know how many instances have been created.
 *
 * `instances_physics` reports how many instances were created inside `_physics_process`.
 *
 * `total_time_spent_usec` reports the time in microseconds spent to process everything and display the geometry on the screen.
 */
class DebugDraw3DStats {
private:
	void *inst_ptr;

public:
	DebugDraw3DStats(void *inst_ptr) :
			inst_ptr(inst_ptr) {}

	DebugDraw3DStats(bool instantiate = true) :
			inst_ptr(instantiate ? create() : create_nullptr()) {}

	~DebugDraw3DStats() { destroy(inst_ptr); }

	operator void *() const { return inst_ptr; }

	int64_t get_instances() {
		static int64_t (*DebugDraw3DStats_get_instances)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_instances, {}, inst_ptr);
	}

	void set_instances(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_instances)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_instances, inst_ptr, val);
#endif
	}

	int64_t get_lines() {
		static int64_t (*DebugDraw3DStats_get_lines)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_lines, {}, inst_ptr);
	}

	void set_lines(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_lines)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_lines, inst_ptr, val);
#endif
	}

	int64_t get_instances_physics() {
		static int64_t (*DebugDraw3DStats_get_instances_physics)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_instances_physics, {}, inst_ptr);
	}

	void set_instances_physics(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_instances_physics)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_instances_physics, inst_ptr, val);
#endif
	}

	int64_t get_lines_physics() {
		static int64_t (*DebugDraw3DStats_get_lines_physics)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_lines_physics, {}, inst_ptr);
	}

	void set_lines_physics(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_lines_physics)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_lines_physics, inst_ptr, val);
#endif
	}

	int64_t get_total_geometry() {
		static int64_t (*DebugDraw3DStats_get_total_geometry)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_total_geometry, {}, inst_ptr);
	}

	void set_total_geometry(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_total_geometry)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_total_geometry, inst_ptr, val);
#endif
	}

	int64_t get_visible_instances() {
		static int64_t (*DebugDraw3DStats_get_visible_instances)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_visible_instances, {}, inst_ptr);
	}

	void set_visible_instances(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_visible_instances)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_visible_instances, inst_ptr, val);
#endif
	}

	int64_t get_visible_lines() {
		static int64_t (*DebugDraw3DStats_get_visible_lines)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_visible_lines, {}, inst_ptr);
	}

	void set_visible_lines(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_visible_lines)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_visible_lines, inst_ptr, val);
#endif
	}

	int64_t get_total_visible() {
		static int64_t (*DebugDraw3DStats_get_total_visible)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_total_visible, {}, inst_ptr);
	}

	void set_total_visible(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_total_visible)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_total_visible, inst_ptr, val);
#endif
	}

	int64_t get_time_filling_buffers_instances_usec() {
		static int64_t (*DebugDraw3DStats_get_time_filling_buffers_instances_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_filling_buffers_instances_usec, {}, inst_ptr);
	}

	void set_time_filling_buffers_instances_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_filling_buffers_instances_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_filling_buffers_instances_usec, inst_ptr, val);
#endif
	}

	int64_t get_time_filling_buffers_lines_usec() {
		static int64_t (*DebugDraw3DStats_get_time_filling_buffers_lines_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_filling_buffers_lines_usec, {}, inst_ptr);
	}

	void set_time_filling_buffers_lines_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_filling_buffers_lines_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_filling_buffers_lines_usec, inst_ptr, val);
#endif
	}

	int64_t get_time_filling_buffers_instances_physics_usec() {
		static int64_t (*DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec, {}, inst_ptr);
	}

	void set_time_filling_buffers_instances_physics_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec, inst_ptr, val);
#endif
	}

	int64_t get_time_filling_buffers_lines_physics_usec() {
		static int64_t (*DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec, {}, inst_ptr);
	}

	void set_time_filling_buffers_lines_physics_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec, inst_ptr, val);
#endif
	}

	int64_t get_total_time_filling_buffers_usec() {
		static int64_t (*DebugDraw3DStats_get_total_time_filling_buffers_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_total_time_filling_buffers_usec, {}, inst_ptr);
	}

	void set_total_time_filling_buffers_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_total_time_filling_buffers_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_total_time_filling_buffers_usec, inst_ptr, val);
#endif
	}

	int64_t get_time_culling_instances_usec() {
		static int64_t (*DebugDraw3DStats_get_time_culling_instances_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_culling_instances_usec, {}, inst_ptr);
	}

	void set_time_culling_instances_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_culling_instances_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_culling_instances_usec, inst_ptr, val);
#endif
	}

	int64_t get_time_culling_lines_usec() {
		static int64_t (*DebugDraw3DStats_get_time_culling_lines_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_time_culling_lines_usec, {}, inst_ptr);
	}

	void set_time_culling_lines_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_time_culling_lines_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_time_culling_lines_usec, inst_ptr, val);
#endif
	}

	int64_t get_total_time_culling_usec() {
		static int64_t (*DebugDraw3DStats_get_total_time_culling_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_total_time_culling_usec, {}, inst_ptr);
	}

	void set_total_time_culling_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_total_time_culling_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_total_time_culling_usec, inst_ptr, val);
#endif
	}

	int64_t get_total_time_spent_usec() {
		static int64_t (*DebugDraw3DStats_get_total_time_spent_usec)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_total_time_spent_usec, {}, inst_ptr);
	}

	void set_total_time_spent_usec(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_total_time_spent_usec)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_total_time_spent_usec, inst_ptr, val);
#endif
	}

	int64_t get_created_scoped_configs() {
		static int64_t (*DebugDraw3DStats_get_created_scoped_configs)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_created_scoped_configs, {}, inst_ptr);
	}

	void set_created_scoped_configs(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_created_scoped_configs)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_created_scoped_configs, inst_ptr, val);
#endif
	}

	int64_t get_orphan_scoped_configs() {
		static int64_t (*DebugDraw3DStats_get_orphan_scoped_configs)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_orphan_scoped_configs, {}, inst_ptr);
	}

	void set_orphan_scoped_configs(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_orphan_scoped_configs)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_orphan_scoped_configs, inst_ptr, val);
#endif
	}

	int64_t get_nodes_label3d_visible() {
		static int64_t (*DebugDraw3DStats_get_nodes_label3d_visible)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_nodes_label3d_visible, {}, inst_ptr);
	}

	void set_nodes_label3d_visible(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_nodes_label3d_visible)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_nodes_label3d_visible, inst_ptr, val);
#endif
	}

	int64_t get_nodes_label3d_visible_physics() {
		static int64_t (*DebugDraw3DStats_get_nodes_label3d_visible_physics)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_nodes_label3d_visible_physics, {}, inst_ptr);
	}

	void set_nodes_label3d_visible_physics(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_nodes_label3d_visible_physics)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_nodes_label3d_visible_physics, inst_ptr, val);
#endif
	}

	int64_t get_nodes_label3d_exists() {
		static int64_t (*DebugDraw3DStats_get_nodes_label3d_exists)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_nodes_label3d_exists, {}, inst_ptr);
	}

	void set_nodes_label3d_exists(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_nodes_label3d_exists)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_nodes_label3d_exists, inst_ptr, val);
#endif
	}

	int64_t get_nodes_label3d_exists_physics() {
		static int64_t (*DebugDraw3DStats_get_nodes_label3d_exists_physics)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_nodes_label3d_exists_physics, {}, inst_ptr);
	}

	void set_nodes_label3d_exists_physics(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_nodes_label3d_exists_physics)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_nodes_label3d_exists_physics, inst_ptr, val);
#endif
	}

	int64_t get_nodes_label3d_exists_total() {
		static int64_t (*DebugDraw3DStats_get_nodes_label3d_exists_total)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_get_nodes_label3d_exists_total, {}, inst_ptr);
	}

	void set_nodes_label3d_exists_total(const int64_t &val) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
		static void (*DebugDraw3DStats_set_nodes_label3d_exists_total)(void * /*inst_ptr*/, int64_t /*val*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_set_nodes_label3d_exists_total, inst_ptr, val);
#endif
	}

private:
	static void * create() {
		static void * (*DebugDraw3DStats_create)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_create, nullptr);
	}

	static void * create_nullptr() {
		static void * (*DebugDraw3DStats_create_nullptr)() = nullptr;
		LOAD_AND_CALL_FUNC_POINTER_RET(DebugDraw3DStats_create_nullptr, nullptr);
	}

	static void destroy(void * inst_ptr) {
		static void (*DebugDraw3DStats_destroy)(void * /*inst_ptr*/) = nullptr;
		LOAD_AND_CALL_FUNC_POINTER(DebugDraw3DStats_destroy, inst_ptr);
	}

}; // class DebugDraw3DStats

/**
 * @brief
 * The main singleton class that handles DebugDraw2D and DebugDraw3D.
 *
 * Several additional settings can be found in the project settings.
 *
 * @note The following settings require a restart.
 *
 * `debug_draw_3d/settings/initial_debug_state` sets the initial debugging state.
 *
 * `debug_draw_3d/settings/common/DebugDrawManager_singleton_aliases` sets aliases for DebugDrawManager to be registered as additional singletons.
 *
 * `debug_draw_3d/settings/common/DebugDraw2D_singleton_aliases` sets aliases for DebugDraw2D to be registered as additional singletons.
 *
 * `debug_draw_3d/settings/common/DebugDraw3D_singleton_aliases` sets aliases for DebugDraw3D to be registered as additional singletons.
 *
 * Using these aliases you can reference singletons with shorter words:
 *
 * ```python
 * var _s = Dbg3.new_scoped_config().set_thickness(0.025).set_center_brightness(0.7)
 * Dbg3.draw_grid_xf(%Grid.global_transform, Vector2i(10,10), Color.LIGHT_GRAY)
 * Dbg2.set_text("Frametime", delta)
 * ```
 */
namespace DebugDrawManager {
/**
 * Clear all 2D and 3D geometry
 */
static void clear_all() {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDrawManager_clear_all)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDrawManager_clear_all);
#endif
}

/**
 * Set whether to display 2D and 3D debug graphics
 */
static void set_debug_enabled(const bool &value) {
#ifdef _DD3D_RUNTIME_CHECK_ENABLED
	static void (*DebugDrawManager_set_debug_enabled)(bool /*value*/) = nullptr;
	LOAD_AND_CALL_FUNC_POINTER(DebugDrawManager_set_debug_enabled, value);
#endif
}

/**
 * Whether debug 2D and 3D graphics are disabled
 */
static bool is_debug_enabled() {
	static bool (*DebugDrawManager_is_debug_enabled)() = nullptr;
	LOAD_AND_CALL_FUNC_POINTER_RET(DebugDrawManager_is_debug_enabled, {});
}

} // namespace DebugDrawManager

// End of the generated API

#undef _DD3D_RUNTIME_CHECK_ENABLED

#undef FUNC_GET_SIGNATURE
#undef LOADING_RESULT
#undef LOAD_FUNC_AND_STORE_RESULT
#undef IS_FIRST_LOADING
#undef IS_LOADED_SUCCESSFULLY
#undef IS_FAILED_TO_LOAD

#undef LOAD_AND_CALL_FUNC_POINTER
#undef LOAD_AND_CALL_FUNC_POINTER_SELFRET
#undef LOAD_AND_CALL_FUNC_POINTER_RET
#undef LOAD_AND_CALL_FUNC_POINTER_RET_CAST
#undef LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_OBJECT
#undef LOAD_AND_CALL_FUNC_POINTER_RET_GODOT_REF
#undef LOAD_AND_CALL_FUNC_POINTER_RET_REF_TO_SHARED

#ifdef _NoProfiler
#undef ZoneScoped
#endif
#undef _NoProfiler
