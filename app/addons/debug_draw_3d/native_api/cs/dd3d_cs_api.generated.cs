/// //////////////////////////////////////////////////////////////
/// THIS FILE HAS BEEN GENERATED.
/// THE CHANGES IN THIS FILE WILL BE OVERWRITTEN AFTER THE UPDATE!
/// //////////////////////////////////////////////////////////////

#if !DEBUG && !FORCED_DD3D
#define _DD3D_RUNTIME_CHECK_ENABLED
#endif

#if (!DEBUG || FORCED_DD3D) || (DEBUG && !FORCED_DD3D)
#define _DD3D_COMPILETIME_CHECK_ENABLED
#endif

using Godot;
using System;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using DD3DFuncLoadingResult = InternalDD3DApiLoaderUtils_.LoadingResult;

// Precision is replaced during generation, but can be replaced manually if necessary.
using real_t = float;

internal static class InternalDD3DApiLoaderUtils_
{
    const bool is_debug_enabled =
#if DEBUG
    true;
#else
    false;
#endif
    public static readonly bool IsCallEnabled = is_debug_enabled || OS.HasFeature("forced_dd3d");

    static readonly string log_prefix = "[DD3D C#] ";
    static readonly string get_funcs_is_double_name = "_get_native_functions_is_double";
    static readonly string get_funcs_hash_name = "_get_native_functions_hash";
    static readonly string get_classes_name = "_get_native_classes";
    static readonly string get_funcs_name = "_get_native_functions";

    public enum LoadingResult
    {
        None,
        Success,
        Failure
    };

    static GodotObject dd3d_c = null;
    static bool failed_to_load = false;
    static System.Collections.Generic.Dictionary<Type, int> dd3d_class_sizes = new();

    static GodotObject get_dd3d()
    {
        if (failed_to_load)
            return null;

        if (dd3d_c != null)
            return dd3d_c;

        if (Engine.HasSingleton("DebugDrawManager"))
        {
            GodotObject dd3d = Engine.GetSingleton("DebugDrawManager");

            if (!dd3d.HasMethod(get_funcs_is_double_name))
            {
                GD.PrintErr(log_prefix, get_funcs_is_double_name, " not found!");
                failed_to_load = true;
                return null;
            }

            bool is_double = OS.HasFeature("double");

            if (dd3d.Call(get_funcs_is_double_name).AsBool() != is_double)
            {
                GD.PrintErr(log_prefix, "The precision of Vectors and Matrices of DD3D and the current library do not match!");
                failed_to_load = true;
                return null;
            }

            foreach (string name in new string[] { get_funcs_hash_name, get_classes_name, get_funcs_name })
            {
                if (!dd3d.HasMethod(name))
                {
                    GD.PrintErr(log_prefix, name, " not found!");
                    failed_to_load = true;
                    return null;
                }
            }

            dd3d_c = dd3d;
            return dd3d_c;
        }
        else
        {
            GD.PrintErr(log_prefix, "DebugDrawManager not found! Most likely, DebugDraw3D was not loaded correctly.");
            failed_to_load = true;
        }

        return null;
    }

    static bool _load_function<dlgt_T>(string name, ref dlgt_T func)
    {
        GodotObject dd3d = get_dd3d();
        if (dd3d != null)
        {
            Godot.Collections.Dictionary api = dd3d.Call(get_funcs_name).AsGodotDictionary();
            if (api.ContainsKey(name))
            {
                Godot.Collections.Dictionary func_dict = api[name].AsGodotDictionary();

                // TODO: signature check?

                func = Marshal.GetDelegateForFunctionPointer<dlgt_T>((nint)func_dict["ptr"].AsInt64());
                return true;
            }
            else
            {
                GD.PrintErr(log_prefix, "!!! FUNCTION NOT FOUND !!! function name: ", name);
                return false;
            }
        }
        return false;
    }

    static int _get_class_size(Type cls)
    {
        GodotObject dd3d = get_dd3d();
        if (dd3d != null)
        {
            Godot.Collections.Dictionary api = dd3d.Call(get_classes_name).AsGodotDictionary();
            if (api.ContainsKey(cls.Name))
            {
                Godot.Collections.Dictionary cls_dict = api[cls.Name].AsGodotDictionary();

                var size = cls_dict["size"].AsInt32();
                dd3d_class_sizes[cls] = size;
                return size;
            }
            else
            {
                GD.PrintErr(log_prefix, "!!! CLASS NOT FOUND !!! class name: ", cls.Name);
                return -1; // crash
            }
        }
        return -1; // crash
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool LoadFunction<dlgt_T>(string name, ref dlgt_T func, ref DD3DFuncLoadingResult result)
    {
        if (result == DD3DFuncLoadingResult.None)
            result = _load_function(name, ref func) ? DD3DFuncLoadingResult.Success : DD3DFuncLoadingResult.Failure;
        if (result == DD3DFuncLoadingResult.Failure)
            return false;
        return true;
    }

    public static int GetDD3DClassSize(Type cls)
    {
        if (dd3d_class_sizes.TryGetValue(cls, out int val))
            return val;
        else
            return _get_class_size(cls);
    }

    public static readonly Color _default_arg_0 = new Color(0.96f, 0.96f, 0.96f, 1.0f);
    public static readonly Color _default_arg_1 = new Color(0, 0, 0, 0);
    public static readonly Vector3 _default_arg_2 = new Vector3(real_t.PositiveInfinity, real_t.PositiveInfinity, real_t.PositiveInfinity);
}

// Start of the generated API

/// <summary>
/// <para>
/// This is a class for storing part of the DebugDraw2D configuration.
/// </para>
///
/// You can use DebugDraw2D.get_config to get the current instance of the configuration.
/// </summary>
internal class DebugDraw2DConfig : IDisposable
{
    public enum BlockPosition : uint
    {
        LeftTop = 0,
        RightTop = 1,
        LeftBottom = 2,
        RightBottom = 3,
    }

    IntPtr inst_ptr;

    public DebugDraw2DConfig(IntPtr inst_ptr)
    {
        this.inst_ptr = inst_ptr;
    }

    public DebugDraw2DConfig(bool instantiate = true)
    {
        this.inst_ptr = instantiate ? Create() : CreateNullptr();
    }

    ~DebugDraw2DConfig() => Dispose();

    public static explicit operator IntPtr(DebugDraw2DConfig o) { return o.inst_ptr; }

    public void Dispose()
    {
        if (inst_ptr != IntPtr.Zero)
        {
            Destroy(inst_ptr);
            inst_ptr = IntPtr.Zero;
        }
    }

    /// <summary>
    /// Position of the text block
    /// </summary>
    public DebugDraw2DConfig.BlockPosition TextBlockPosition { get => GetTextBlockPosition(); set => SetTextBlockPosition(value); }

    /// <summary>
    /// Offset from the corner selected in 'set_text_block_position'
    /// </summary>
    public Vector2I TextBlockOffset { get => GetTextBlockOffset(); set => SetTextBlockOffset(value); }

    /// <summary>
    /// Text padding for each line
    /// </summary>
    public Vector2I TextPadding { get => GetTextPadding(); set => SetTextPadding(value); }

    /// <summary>
    /// How long the text remains visible after creation.
    /// </summary>
    public real_t TextDefaultDuration { get => GetTextDefaultDuration(); set => SetTextDefaultDuration(value); }

    /// <summary>
    /// Default text size
    /// </summary>
    public int TextDefaultSize { get => GetTextDefaultSize(); set => SetTextDefaultSize(value); }

    /// <summary>
    /// Default color of the text
    /// </summary>
    public Color TextForegroundColor { get => GetTextForegroundColor(); set => SetTextForegroundColor(value); }

    /// <summary>
    /// Background color of the text
    /// </summary>
    public Color TextBackgroundColor { get => GetTextBackgroundColor(); set => SetTextBackgroundColor(value); }

    /// <summary>
    /// Custom text Font
    /// </summary>
    public Font TextCustomFont { get => GetTextCustomFont(); set => SetTextCustomFont(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_block_position(IntPtr inst_ptr, uint /*DebugDraw2DConfig::BlockPosition*/ _position);
    static dlgt_DebugDraw2DConfig_set_text_block_position func_DebugDraw2DConfig_set_text_block_position; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_block_position;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate uint /*DebugDraw2DConfig::BlockPosition*/ dlgt_DebugDraw2DConfig_get_text_block_position(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_block_position func_DebugDraw2DConfig_get_text_block_position; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_block_position;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_block_offset(IntPtr inst_ptr, Vector2I _offset);
    static dlgt_DebugDraw2DConfig_set_text_block_offset func_DebugDraw2DConfig_set_text_block_offset; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_block_offset;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Vector2I dlgt_DebugDraw2DConfig_get_text_block_offset(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_block_offset func_DebugDraw2DConfig_get_text_block_offset; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_block_offset;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_padding(IntPtr inst_ptr, Vector2I _padding);
    static dlgt_DebugDraw2DConfig_set_text_padding func_DebugDraw2DConfig_set_text_padding; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_padding;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Vector2I dlgt_DebugDraw2DConfig_get_text_padding(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_padding func_DebugDraw2DConfig_get_text_padding; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_padding;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_default_duration(IntPtr inst_ptr, real_t _duration);
    static dlgt_DebugDraw2DConfig_set_text_default_duration func_DebugDraw2DConfig_set_text_default_duration; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_default_duration;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate real_t dlgt_DebugDraw2DConfig_get_text_default_duration(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_default_duration func_DebugDraw2DConfig_get_text_default_duration; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_default_duration;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_default_size(IntPtr inst_ptr, int _size);
    static dlgt_DebugDraw2DConfig_set_text_default_size func_DebugDraw2DConfig_set_text_default_size; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_default_size;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int dlgt_DebugDraw2DConfig_get_text_default_size(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_default_size func_DebugDraw2DConfig_get_text_default_size; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_default_size;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_foreground_color(IntPtr inst_ptr, Color _new_color);
    static dlgt_DebugDraw2DConfig_set_text_foreground_color func_DebugDraw2DConfig_set_text_foreground_color; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_foreground_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Color dlgt_DebugDraw2DConfig_get_text_foreground_color(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_foreground_color func_DebugDraw2DConfig_get_text_foreground_color; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_foreground_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_background_color(IntPtr inst_ptr, Color _new_color);
    static dlgt_DebugDraw2DConfig_set_text_background_color func_DebugDraw2DConfig_set_text_background_color; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_background_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Color dlgt_DebugDraw2DConfig_get_text_background_color(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_background_color func_DebugDraw2DConfig_get_text_background_color; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_background_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_set_text_custom_font(IntPtr inst_ptr, ulong _custom_font);
    static dlgt_DebugDraw2DConfig_set_text_custom_font func_DebugDraw2DConfig_set_text_custom_font; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_set_text_custom_font;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate ulong dlgt_DebugDraw2DConfig_get_text_custom_font(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_get_text_custom_font func_DebugDraw2DConfig_get_text_custom_font; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_get_text_custom_font;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2DConfig_create();
    static dlgt_DebugDraw2DConfig_create func_DebugDraw2DConfig_create; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_create;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2DConfig_create_nullptr();
    static dlgt_DebugDraw2DConfig_create_nullptr func_DebugDraw2DConfig_create_nullptr; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_create_nullptr;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DConfig_destroy(IntPtr inst_ptr);
    static dlgt_DebugDraw2DConfig_destroy func_DebugDraw2DConfig_destroy; static DD3DFuncLoadingResult func_load_result_DebugDraw2DConfig_destroy;

    /// <summary>
    /// Position of the text block
    /// </summary>
    public void SetTextBlockPosition(DebugDraw2DConfig.BlockPosition _position)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_block_position", ref func_DebugDraw2DConfig_set_text_block_position, ref func_load_result_DebugDraw2DConfig_set_text_block_position))
                return;
            func_DebugDraw2DConfig_set_text_block_position(inst_ptr, (uint)(_position));
#endif
        }
    }

    public DebugDraw2DConfig.BlockPosition GetTextBlockPosition()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_block_position", ref func_DebugDraw2DConfig_get_text_block_position, ref func_load_result_DebugDraw2DConfig_get_text_block_position))
            return default;
        return (DebugDraw2DConfig.BlockPosition)func_DebugDraw2DConfig_get_text_block_position(inst_ptr);
    }

    /// <summary>
    /// Offset from the corner selected in 'set_text_block_position'
    /// </summary>
    public void SetTextBlockOffset(Vector2I _offset)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_block_offset", ref func_DebugDraw2DConfig_set_text_block_offset, ref func_load_result_DebugDraw2DConfig_set_text_block_offset))
                return;
            func_DebugDraw2DConfig_set_text_block_offset(inst_ptr, _offset);
#endif
        }
    }

    public Vector2I GetTextBlockOffset()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_block_offset", ref func_DebugDraw2DConfig_get_text_block_offset, ref func_load_result_DebugDraw2DConfig_get_text_block_offset))
            return default;
        return func_DebugDraw2DConfig_get_text_block_offset(inst_ptr);
    }

    /// <summary>
    /// Text padding for each line
    /// </summary>
    public void SetTextPadding(Vector2I _padding)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_padding", ref func_DebugDraw2DConfig_set_text_padding, ref func_load_result_DebugDraw2DConfig_set_text_padding))
                return;
            func_DebugDraw2DConfig_set_text_padding(inst_ptr, _padding);
#endif
        }
    }

    public Vector2I GetTextPadding()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_padding", ref func_DebugDraw2DConfig_get_text_padding, ref func_load_result_DebugDraw2DConfig_get_text_padding))
            return default;
        return func_DebugDraw2DConfig_get_text_padding(inst_ptr);
    }

    /// <summary>
    /// How long the text remains visible after creation.
    /// </summary>
    public void SetTextDefaultDuration(real_t _duration)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_default_duration", ref func_DebugDraw2DConfig_set_text_default_duration, ref func_load_result_DebugDraw2DConfig_set_text_default_duration))
                return;
            func_DebugDraw2DConfig_set_text_default_duration(inst_ptr, _duration);
#endif
        }
    }

    public real_t GetTextDefaultDuration()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_default_duration", ref func_DebugDraw2DConfig_get_text_default_duration, ref func_load_result_DebugDraw2DConfig_get_text_default_duration))
            return default;
        return func_DebugDraw2DConfig_get_text_default_duration(inst_ptr);
    }

    /// <summary>
    /// Default text size
    /// </summary>
    public void SetTextDefaultSize(int _size)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_default_size", ref func_DebugDraw2DConfig_set_text_default_size, ref func_load_result_DebugDraw2DConfig_set_text_default_size))
                return;
            func_DebugDraw2DConfig_set_text_default_size(inst_ptr, _size);
#endif
        }
    }

    public int GetTextDefaultSize()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_default_size", ref func_DebugDraw2DConfig_get_text_default_size, ref func_load_result_DebugDraw2DConfig_get_text_default_size))
            return default;
        return func_DebugDraw2DConfig_get_text_default_size(inst_ptr);
    }

    /// <summary>
    /// Default color of the text
    /// </summary>
    public void SetTextForegroundColor(Color _new_color)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_foreground_color", ref func_DebugDraw2DConfig_set_text_foreground_color, ref func_load_result_DebugDraw2DConfig_set_text_foreground_color))
                return;
            func_DebugDraw2DConfig_set_text_foreground_color(inst_ptr, _new_color);
#endif
        }
    }

    public Color GetTextForegroundColor()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_foreground_color", ref func_DebugDraw2DConfig_get_text_foreground_color, ref func_load_result_DebugDraw2DConfig_get_text_foreground_color))
            return default;
        return func_DebugDraw2DConfig_get_text_foreground_color(inst_ptr);
    }

    /// <summary>
    /// Background color of the text
    /// </summary>
    public void SetTextBackgroundColor(Color _new_color)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_background_color", ref func_DebugDraw2DConfig_set_text_background_color, ref func_load_result_DebugDraw2DConfig_set_text_background_color))
                return;
            func_DebugDraw2DConfig_set_text_background_color(inst_ptr, _new_color);
#endif
        }
    }

    public Color GetTextBackgroundColor()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_background_color", ref func_DebugDraw2DConfig_get_text_background_color, ref func_load_result_DebugDraw2DConfig_get_text_background_color))
            return default;
        return func_DebugDraw2DConfig_get_text_background_color(inst_ptr);
    }

    /// <summary>
    /// Custom text Font
    /// </summary>
    public void SetTextCustomFont(Font _custom_font)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_set_text_custom_font", ref func_DebugDraw2DConfig_set_text_custom_font, ref func_load_result_DebugDraw2DConfig_set_text_custom_font))
                return;
            func_DebugDraw2DConfig_set_text_custom_font(inst_ptr, _custom_font != null ? _custom_font.GetInstanceId() : 0);
#endif
        }
    }

    public Font GetTextCustomFont()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_get_text_custom_font", ref func_DebugDraw2DConfig_get_text_custom_font, ref func_load_result_DebugDraw2DConfig_get_text_custom_font))
            return default;
        return (Font)GodotObject.InstanceFromId(func_DebugDraw2DConfig_get_text_custom_font(inst_ptr));
    }

    private static IntPtr Create()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_create", ref func_DebugDraw2DConfig_create, ref func_load_result_DebugDraw2DConfig_create))
            return IntPtr.Zero;
        return func_DebugDraw2DConfig_create();
    }

    private static IntPtr CreateNullptr()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_create_nullptr", ref func_DebugDraw2DConfig_create_nullptr, ref func_load_result_DebugDraw2DConfig_create_nullptr))
            return IntPtr.Zero;
        return func_DebugDraw2DConfig_create_nullptr();
    }

    private static void Destroy(IntPtr inst_ptr)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DConfig_destroy", ref func_DebugDraw2DConfig_destroy, ref func_load_result_DebugDraw2DConfig_destroy))
            return;
        func_DebugDraw2DConfig_destroy(inst_ptr);
    }

}; // class DebugDraw2DConfig

/// <summary>
/// <para>
/// Singleton class for calling debugging 2D methods.
/// </para>
///
/// Currently, this class supports drawing an overlay with text.
/// </summary>
internal static class DebugDraw2D
{
    /// <summary>
    /// Set whether debug drawing works or not.
    /// </summary>
    public static bool DebugEnabled { get => IsDebugEnabled(); set => SetDebugEnabled(value); }

    /// <summary>
    /// Set the configuration global for everything in DebugDraw2D.
    /// </summary>
    public static DebugDraw2DConfig Config { get => GetConfig(); set => SetConfig(value); }

    /// <summary>
    /// Set a custom Control to be used as the canvas for drawing the graphic.
    ///
    /// You can use any Control, even one that is in a different window.
    /// </summary>
    public static Control CustomCanvas { get => GetCustomCanvas(); set => SetCustomCanvas(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_set_debug_enabled(bool _state);
    static dlgt_DebugDraw2D_set_debug_enabled func_DebugDraw2D_set_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_set_debug_enabled;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw2D_is_debug_enabled();
    static dlgt_DebugDraw2D_is_debug_enabled func_DebugDraw2D_is_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_is_debug_enabled;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_set_config(IntPtr _cfg);
    static dlgt_DebugDraw2D_set_config func_DebugDraw2D_set_config; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_set_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2D_get_config();
    static dlgt_DebugDraw2D_get_config func_DebugDraw2D_get_config; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_get_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_set_custom_canvas(ulong /*godot::Control*/ _canvas);
    static dlgt_DebugDraw2D_set_custom_canvas func_DebugDraw2D_set_custom_canvas; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_set_custom_canvas;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate ulong dlgt_DebugDraw2D_get_custom_canvas();
    static dlgt_DebugDraw2D_get_custom_canvas func_DebugDraw2D_get_custom_canvas; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_get_custom_canvas;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2D_get_render_stats();
    static dlgt_DebugDraw2D_get_render_stats func_DebugDraw2D_get_render_stats; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_get_render_stats;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_clear_all();
    static dlgt_DebugDraw2D_clear_all func_DebugDraw2D_clear_all; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_clear_all;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_begin_text_group_c([MarshalAs(UnmanagedType.LPUTF8Str)] string /*godot::String*/ group_title_string, int group_priority, Color group_color, bool show_title, int title_size, int text_size);
    static dlgt_DebugDraw2D_begin_text_group_c func_DebugDraw2D_begin_text_group_c; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_begin_text_group_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_end_text_group();
    static dlgt_DebugDraw2D_end_text_group func_DebugDraw2D_end_text_group; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_end_text_group;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_set_text_c([MarshalAs(UnmanagedType.LPUTF8Str)] string /*godot::String*/ key_string, [MarshalAs(UnmanagedType.LPUTF8Str)] string /*godot::String*/ value_string, int priority, Color color_of_value, real_t duration);
    static dlgt_DebugDraw2D_set_text_c func_DebugDraw2D_set_text_c; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_set_text_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2D_clear_texts();
    static dlgt_DebugDraw2D_clear_texts func_DebugDraw2D_clear_texts; static DD3DFuncLoadingResult func_load_result_DebugDraw2D_clear_texts;

    /// <summary>
    /// Set whether debug drawing works or not.
    /// </summary>
    public static void SetDebugEnabled(bool _state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_set_debug_enabled", ref func_DebugDraw2D_set_debug_enabled, ref func_load_result_DebugDraw2D_set_debug_enabled))
                return;
            func_DebugDraw2D_set_debug_enabled(_state);
#endif
        }
    }

    public static bool IsDebugEnabled()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_is_debug_enabled", ref func_DebugDraw2D_is_debug_enabled, ref func_load_result_DebugDraw2D_is_debug_enabled))
            return default;
        return func_DebugDraw2D_is_debug_enabled();
    }

    /// <summary>
    /// Set the configuration global for everything in DebugDraw2D.
    /// </summary>
    public static void SetConfig(DebugDraw2DConfig _cfg)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_set_config", ref func_DebugDraw2D_set_config, ref func_load_result_DebugDraw2D_set_config))
                return;
            func_DebugDraw2D_set_config((IntPtr)_cfg);
#endif
        }
    }

    /// <summary>
    /// Get the DebugDraw2DConfig.
    /// </summary>
    public static DebugDraw2DConfig GetConfig()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_get_config", ref func_DebugDraw2D_get_config, ref func_load_result_DebugDraw2D_get_config))
            return null;
        return new DebugDraw2DConfig(func_DebugDraw2D_get_config());
    }

    /// <summary>
    /// Set a custom Control to be used as the canvas for drawing the graphic.
    ///
    /// You can use any Control, even one that is in a different window.
    /// </summary>
    public static void SetCustomCanvas(Control _canvas)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_set_custom_canvas", ref func_DebugDraw2D_set_custom_canvas, ref func_load_result_DebugDraw2D_set_custom_canvas))
                return;
            func_DebugDraw2D_set_custom_canvas(_canvas != null ? _canvas.GetInstanceId() : 0);
#endif
        }
    }

    public static Control GetCustomCanvas()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_get_custom_canvas", ref func_DebugDraw2D_get_custom_canvas, ref func_load_result_DebugDraw2D_get_custom_canvas))
            return default;
        return (Control)GodotObject.InstanceFromId(func_DebugDraw2D_get_custom_canvas());
    }

    /// <summary>
    /// Returns the DebugDraw2DStats instance with the current statistics.
    ///
    /// Some data can be delayed by 1 frame.
    /// </summary>
    public static DebugDraw2DStats GetRenderStats()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_get_render_stats", ref func_DebugDraw2D_get_render_stats, ref func_load_result_DebugDraw2D_get_render_stats))
            return null;
        return new DebugDraw2DStats(func_DebugDraw2D_get_render_stats());
    }

    /// <summary>
    /// Clear all 2D objects
    /// </summary>
    public static void ClearAll()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_clear_all", ref func_DebugDraw2D_clear_all, ref func_load_result_DebugDraw2D_clear_all))
                return;
            func_DebugDraw2D_clear_all();
#endif
        }
    }

    /// <summary>
    /// Begin a text group to which all of the following text from DebugDraw2D.set_text will be added
    ///
    /// </summary>
    /// <param name="group_title">Group title and ID</param>
    /// <param name="group_priority">Group priority based on which groups will be sorted from top to bottom.</param>
    /// <param name="group_color">Main color of the group</param>
    /// <param name="show_title">Whether to show the title</param>
    /// <param name="title_size">Title font size</param>
    /// <param name="text_size">Text font size</param>
    public static void BeginTextGroup(string group_title, int group_priority = 0, Color? group_color = null, bool show_title = true, int title_size = -1, int text_size = -1)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_begin_text_group_c", ref func_DebugDraw2D_begin_text_group_c, ref func_load_result_DebugDraw2D_begin_text_group_c))
                return;
            func_DebugDraw2D_begin_text_group_c(group_title, group_priority, group_color ?? InternalDD3DApiLoaderUtils_._default_arg_0, show_title, title_size, text_size);
#endif
        }
    }

    /// <summary>
    /// Ends the text group. Should be called after DebugDraw2D.begin_text_group.
    ///
    /// If you need to create multiple groups, just call DebugDraw2D.begin_text_group again and this function at the end.
    /// </summary>
    public static void EndTextGroup()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_end_text_group", ref func_DebugDraw2D_end_text_group, ref func_load_result_DebugDraw2D_end_text_group))
                return;
            func_DebugDraw2D_end_text_group();
#endif
        }
    }

    /// <summary>
    /// Add or update text in an overlay
    ///
    /// </summary>
    /// <param name="key">Left value if 'value' is set, otherwise the entire string is 'key'</param>
    /// <param name="value">Value of field</param>
    /// <param name="priority">Priority of this line. Lower value is higher position</param>
    /// <param name="color_of_value">Value color</param>
    /// <param name="duration">Expiration time</param>
    public static void SetText(string key, string value = "", int priority = 0, Color? color_of_value = null, real_t duration = -1)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_set_text_c", ref func_DebugDraw2D_set_text_c, ref func_load_result_DebugDraw2D_set_text_c))
                return;
            func_DebugDraw2D_set_text_c(key, value, priority, color_of_value ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Clear all text
    /// </summary>
    public static void ClearTexts()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2D_clear_texts", ref func_DebugDraw2D_clear_texts, ref func_load_result_DebugDraw2D_clear_texts))
                return;
            func_DebugDraw2D_clear_texts();
#endif
        }
    }

} // class DebugDraw2D

/// <summary>
/// <para>
/// You can get basic statistics about 2D rendering from this class.
/// </para>
///
/// All names try to reflect what they mean.
///
/// To get an instance of this class with current statistics, use DebugDraw2D.get_render_stats.
/// </summary>
internal class DebugDraw2DStats : IDisposable
{
    IntPtr inst_ptr;

    public DebugDraw2DStats(IntPtr inst_ptr)
    {
        this.inst_ptr = inst_ptr;
    }

    public DebugDraw2DStats(bool instantiate = true)
    {
        this.inst_ptr = instantiate ? Create() : CreateNullptr();
    }

    ~DebugDraw2DStats() => Dispose();

    public static explicit operator IntPtr(DebugDraw2DStats o) { return o.inst_ptr; }

    public void Dispose()
    {
        if (inst_ptr != IntPtr.Zero)
        {
            Destroy(inst_ptr);
            inst_ptr = IntPtr.Zero;
        }
    }

    public long OverlayTextGroups { get => GetOverlayTextGroups(); set => SetOverlayTextGroups(value); }

    public long OverlayTextLines { get => GetOverlayTextLines(); set => SetOverlayTextLines(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw2DStats_get_overlay_text_groups(IntPtr inst_ptr);
    static dlgt_DebugDraw2DStats_get_overlay_text_groups func_DebugDraw2DStats_get_overlay_text_groups; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_get_overlay_text_groups;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DStats_set_overlay_text_groups(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw2DStats_set_overlay_text_groups func_DebugDraw2DStats_set_overlay_text_groups; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_set_overlay_text_groups;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw2DStats_get_overlay_text_lines(IntPtr inst_ptr);
    static dlgt_DebugDraw2DStats_get_overlay_text_lines func_DebugDraw2DStats_get_overlay_text_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_get_overlay_text_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DStats_set_overlay_text_lines(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw2DStats_set_overlay_text_lines func_DebugDraw2DStats_set_overlay_text_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_set_overlay_text_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2DStats_create();
    static dlgt_DebugDraw2DStats_create func_DebugDraw2DStats_create; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_create;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw2DStats_create_nullptr();
    static dlgt_DebugDraw2DStats_create_nullptr func_DebugDraw2DStats_create_nullptr; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_create_nullptr;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw2DStats_destroy(IntPtr inst_ptr);
    static dlgt_DebugDraw2DStats_destroy func_DebugDraw2DStats_destroy; static DD3DFuncLoadingResult func_load_result_DebugDraw2DStats_destroy;

    public long GetOverlayTextGroups()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_get_overlay_text_groups", ref func_DebugDraw2DStats_get_overlay_text_groups, ref func_load_result_DebugDraw2DStats_get_overlay_text_groups))
            return default;
        return func_DebugDraw2DStats_get_overlay_text_groups(inst_ptr);
    }

    public void SetOverlayTextGroups(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_set_overlay_text_groups", ref func_DebugDraw2DStats_set_overlay_text_groups, ref func_load_result_DebugDraw2DStats_set_overlay_text_groups))
                return;
            func_DebugDraw2DStats_set_overlay_text_groups(inst_ptr, val);
#endif
        }
    }

    public long GetOverlayTextLines()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_get_overlay_text_lines", ref func_DebugDraw2DStats_get_overlay_text_lines, ref func_load_result_DebugDraw2DStats_get_overlay_text_lines))
            return default;
        return func_DebugDraw2DStats_get_overlay_text_lines(inst_ptr);
    }

    public void SetOverlayTextLines(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_set_overlay_text_lines", ref func_DebugDraw2DStats_set_overlay_text_lines, ref func_load_result_DebugDraw2DStats_set_overlay_text_lines))
                return;
            func_DebugDraw2DStats_set_overlay_text_lines(inst_ptr, val);
#endif
        }
    }

    private static IntPtr Create()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_create", ref func_DebugDraw2DStats_create, ref func_load_result_DebugDraw2DStats_create))
            return IntPtr.Zero;
        return func_DebugDraw2DStats_create();
    }

    private static IntPtr CreateNullptr()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_create_nullptr", ref func_DebugDraw2DStats_create_nullptr, ref func_load_result_DebugDraw2DStats_create_nullptr))
            return IntPtr.Zero;
        return func_DebugDraw2DStats_create_nullptr();
    }

    private static void Destroy(IntPtr inst_ptr)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw2DStats_destroy", ref func_DebugDraw2DStats_destroy, ref func_load_result_DebugDraw2DStats_destroy))
            return;
        func_DebugDraw2DStats_destroy(inst_ptr);
    }

}; // class DebugDraw2DStats

/// <summary>
/// <para>
/// This is a class for storing part of the DebugDraw3D configuration.
/// </para>
///
/// You can use DebugDraw3D.get_config to get the current instance of the configuration.
/// </summary>
internal class DebugDraw3DConfig : IDisposable
{
    public enum CullingMode : uint
    {
        Disabled = 0,
        Rough = 1,
        Precise = 2,
    }

    IntPtr inst_ptr;

    public DebugDraw3DConfig(IntPtr inst_ptr)
    {
        this.inst_ptr = inst_ptr;
    }

    public DebugDraw3DConfig(bool instantiate = true)
    {
        this.inst_ptr = instantiate ? Create() : CreateNullptr();
    }

    ~DebugDraw3DConfig() => Dispose();

    public static explicit operator IntPtr(DebugDraw3DConfig o) { return o.inst_ptr; }

    public void Dispose()
    {
        if (inst_ptr != IntPtr.Zero)
        {
            Destroy(inst_ptr);
            inst_ptr = IntPtr.Zero;
        }
    }

    /// <summary>
    /// Set whether debug 3D graphics rendering is frozen.
    /// This means that previously created geometry will not be updated until set to false or until DebugDraw3D.clear_all is called.
    /// </summary>
    public bool Freeze3dRender { get => IsFreeze3dRender(); set => SetFreeze3dRender(value); }

    /// <summary>
    /// Set whether the boundaries of instances are displayed.
    /// Based on these boundaries, instances are culled if set_use_frustum_culling is activated.
    /// </summary>
    public bool VisibleInstanceBounds { get => IsVisibleInstanceBounds(); set => SetVisibleInstanceBounds(value); }

    /// <summary>
    /// <para>Deprecated</para>
    /// Set whether frustum culling is used.
    /// This is a wrapper over DebugDraw3DConfig.set_frustum_culling_mode and exists for compatibility with older versions.
    ///
    /// <para>
    /// Enabling or disabling this option does not affect the rough culling based on the camera's AABB of frustum.
    /// This option enables more accurate culling based on the camera's frustum planes.
    /// </para>
    /// </summary>
    public bool UseFrustumCulling { get => IsUseFrustumCulling(); set => SetUseFrustumCulling(value); }

    /// <summary>
    /// Set frustum culling mode.
    /// </summary>
    public DebugDraw3DConfig.CullingMode FrustumCullingMode { get => GetFrustumCullingMode(); set => SetFrustumCullingMode(value); }

    /// <summary>
    /// Change the distance between the Far and Near Planes of the Viewport's Camera3D.
    /// </summary>
    public real_t FrustumLengthScale { get => GetFrustumLengthScale(); set => SetFrustumLengthScale(value); }

    /// <summary>
    /// Set the forced use of the scene camera instead of the editor camera.
    /// </summary>
    public bool ForceUseCameraFromScene { get => IsForceUseCameraFromScene(); set => SetForceUseCameraFromScene(value); }

    /// <summary>
    /// Set the visibility layer on which the 3D geometry will be drawn.
    /// Similar to using VisualInstance3D.layers.
    /// </summary>
    public int GeometryRenderLayers { get => GetGeometryRenderLayers(); set => SetGeometryRenderLayers(value); }

    /// <summary>
    /// Set the default color for the collision point of DebugDraw3D.draw_line_hit.
    /// </summary>
    public Color LineHitColor { get => GetLineHitColor(); set => SetLineHitColor(value); }

    /// <summary>
    /// Set the default color for the line after the collision point of DebugDraw3D.draw_line_hit.
    /// </summary>
    public Color LineAfterHitColor { get => GetLineAfterHitColor(); set => SetLineAfterHitColor(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_freeze_3d_render(IntPtr inst_ptr, bool _state);
    static dlgt_DebugDraw3DConfig_set_freeze_3d_render func_DebugDraw3DConfig_set_freeze_3d_render; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_freeze_3d_render;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DConfig_is_freeze_3d_render(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_is_freeze_3d_render func_DebugDraw3DConfig_is_freeze_3d_render; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_is_freeze_3d_render;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_visible_instance_bounds(IntPtr inst_ptr, bool _state);
    static dlgt_DebugDraw3DConfig_set_visible_instance_bounds func_DebugDraw3DConfig_set_visible_instance_bounds; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_visible_instance_bounds;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DConfig_is_visible_instance_bounds(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_is_visible_instance_bounds func_DebugDraw3DConfig_is_visible_instance_bounds; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_is_visible_instance_bounds;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_use_frustum_culling(IntPtr inst_ptr, bool _state);
    static dlgt_DebugDraw3DConfig_set_use_frustum_culling func_DebugDraw3DConfig_set_use_frustum_culling; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_use_frustum_culling;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DConfig_is_use_frustum_culling(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_is_use_frustum_culling func_DebugDraw3DConfig_is_use_frustum_culling; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_is_use_frustum_culling;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_frustum_culling_mode(IntPtr inst_ptr, uint /*DebugDraw3DConfig::CullingMode*/ _mode);
    static dlgt_DebugDraw3DConfig_set_frustum_culling_mode func_DebugDraw3DConfig_set_frustum_culling_mode; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_frustum_culling_mode;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate uint /*DebugDraw3DConfig::CullingMode*/ dlgt_DebugDraw3DConfig_get_frustum_culling_mode(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_get_frustum_culling_mode func_DebugDraw3DConfig_get_frustum_culling_mode; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_get_frustum_culling_mode;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_frustum_length_scale(IntPtr inst_ptr, real_t _distance);
    static dlgt_DebugDraw3DConfig_set_frustum_length_scale func_DebugDraw3DConfig_set_frustum_length_scale; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_frustum_length_scale;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate real_t dlgt_DebugDraw3DConfig_get_frustum_length_scale(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_get_frustum_length_scale func_DebugDraw3DConfig_get_frustum_length_scale; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_get_frustum_length_scale;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_force_use_camera_from_scene(IntPtr inst_ptr, bool _state);
    static dlgt_DebugDraw3DConfig_set_force_use_camera_from_scene func_DebugDraw3DConfig_set_force_use_camera_from_scene; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_force_use_camera_from_scene;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DConfig_is_force_use_camera_from_scene(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_is_force_use_camera_from_scene func_DebugDraw3DConfig_is_force_use_camera_from_scene; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_is_force_use_camera_from_scene;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_geometry_render_layers(IntPtr inst_ptr, int _layers);
    static dlgt_DebugDraw3DConfig_set_geometry_render_layers func_DebugDraw3DConfig_set_geometry_render_layers; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_geometry_render_layers;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int dlgt_DebugDraw3DConfig_get_geometry_render_layers(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_get_geometry_render_layers func_DebugDraw3DConfig_get_geometry_render_layers; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_get_geometry_render_layers;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_line_hit_color(IntPtr inst_ptr, Color _new_color);
    static dlgt_DebugDraw3DConfig_set_line_hit_color func_DebugDraw3DConfig_set_line_hit_color; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_line_hit_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Color dlgt_DebugDraw3DConfig_get_line_hit_color(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_get_line_hit_color func_DebugDraw3DConfig_get_line_hit_color; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_get_line_hit_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_set_line_after_hit_color(IntPtr inst_ptr, Color _new_color);
    static dlgt_DebugDraw3DConfig_set_line_after_hit_color func_DebugDraw3DConfig_set_line_after_hit_color; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_set_line_after_hit_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Color dlgt_DebugDraw3DConfig_get_line_after_hit_color(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_get_line_after_hit_color func_DebugDraw3DConfig_get_line_after_hit_color; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_get_line_after_hit_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DConfig_create();
    static dlgt_DebugDraw3DConfig_create func_DebugDraw3DConfig_create; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_create;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DConfig_create_nullptr();
    static dlgt_DebugDraw3DConfig_create_nullptr func_DebugDraw3DConfig_create_nullptr; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_create_nullptr;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DConfig_destroy(IntPtr inst_ptr);
    static dlgt_DebugDraw3DConfig_destroy func_DebugDraw3DConfig_destroy; static DD3DFuncLoadingResult func_load_result_DebugDraw3DConfig_destroy;

    /// <summary>
    /// Set whether debug 3D graphics rendering is frozen.
    /// This means that previously created geometry will not be updated until set to false or until DebugDraw3D.clear_all is called.
    /// </summary>
    public void SetFreeze3dRender(bool _state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_freeze_3d_render", ref func_DebugDraw3DConfig_set_freeze_3d_render, ref func_load_result_DebugDraw3DConfig_set_freeze_3d_render))
                return;
            func_DebugDraw3DConfig_set_freeze_3d_render(inst_ptr, _state);
#endif
        }
    }

    public bool IsFreeze3dRender()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_is_freeze_3d_render", ref func_DebugDraw3DConfig_is_freeze_3d_render, ref func_load_result_DebugDraw3DConfig_is_freeze_3d_render))
            return default;
        return func_DebugDraw3DConfig_is_freeze_3d_render(inst_ptr);
    }

    /// <summary>
    /// Set whether the boundaries of instances are displayed.
    /// Based on these boundaries, instances are culled if set_use_frustum_culling is activated.
    /// </summary>
    public void SetVisibleInstanceBounds(bool _state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_visible_instance_bounds", ref func_DebugDraw3DConfig_set_visible_instance_bounds, ref func_load_result_DebugDraw3DConfig_set_visible_instance_bounds))
                return;
            func_DebugDraw3DConfig_set_visible_instance_bounds(inst_ptr, _state);
#endif
        }
    }

    public bool IsVisibleInstanceBounds()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_is_visible_instance_bounds", ref func_DebugDraw3DConfig_is_visible_instance_bounds, ref func_load_result_DebugDraw3DConfig_is_visible_instance_bounds))
            return default;
        return func_DebugDraw3DConfig_is_visible_instance_bounds(inst_ptr);
    }

    /// <summary>
    /// <para>Deprecated</para>
    /// Set whether frustum culling is used.
    /// This is a wrapper over DebugDraw3DConfig.set_frustum_culling_mode and exists for compatibility with older versions.
    ///
    /// <para>
    /// Enabling or disabling this option does not affect the rough culling based on the camera's AABB of frustum.
    /// This option enables more accurate culling based on the camera's frustum planes.
    /// </para>
    /// </summary>
    public void SetUseFrustumCulling(bool _state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_use_frustum_culling", ref func_DebugDraw3DConfig_set_use_frustum_culling, ref func_load_result_DebugDraw3DConfig_set_use_frustum_culling))
                return;
            func_DebugDraw3DConfig_set_use_frustum_culling(inst_ptr, _state);
#endif
        }
    }

    public bool IsUseFrustumCulling()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_is_use_frustum_culling", ref func_DebugDraw3DConfig_is_use_frustum_culling, ref func_load_result_DebugDraw3DConfig_is_use_frustum_culling))
            return default;
        return func_DebugDraw3DConfig_is_use_frustum_culling(inst_ptr);
    }

    /// <summary>
    /// Set frustum culling mode.
    /// </summary>
    public void SetFrustumCullingMode(DebugDraw3DConfig.CullingMode _mode)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_frustum_culling_mode", ref func_DebugDraw3DConfig_set_frustum_culling_mode, ref func_load_result_DebugDraw3DConfig_set_frustum_culling_mode))
                return;
            func_DebugDraw3DConfig_set_frustum_culling_mode(inst_ptr, (uint)(_mode));
#endif
        }
    }

    public DebugDraw3DConfig.CullingMode GetFrustumCullingMode()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_get_frustum_culling_mode", ref func_DebugDraw3DConfig_get_frustum_culling_mode, ref func_load_result_DebugDraw3DConfig_get_frustum_culling_mode))
            return default;
        return (DebugDraw3DConfig.CullingMode)func_DebugDraw3DConfig_get_frustum_culling_mode(inst_ptr);
    }

    /// <summary>
    /// Change the distance between the Far and Near Planes of the Viewport's Camera3D.
    /// </summary>
    public void SetFrustumLengthScale(real_t _distance)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_frustum_length_scale", ref func_DebugDraw3DConfig_set_frustum_length_scale, ref func_load_result_DebugDraw3DConfig_set_frustum_length_scale))
                return;
            func_DebugDraw3DConfig_set_frustum_length_scale(inst_ptr, _distance);
#endif
        }
    }

    public real_t GetFrustumLengthScale()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_get_frustum_length_scale", ref func_DebugDraw3DConfig_get_frustum_length_scale, ref func_load_result_DebugDraw3DConfig_get_frustum_length_scale))
            return default;
        return func_DebugDraw3DConfig_get_frustum_length_scale(inst_ptr);
    }

    /// <summary>
    /// Set the forced use of the scene camera instead of the editor camera.
    /// </summary>
    public void SetForceUseCameraFromScene(bool _state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_force_use_camera_from_scene", ref func_DebugDraw3DConfig_set_force_use_camera_from_scene, ref func_load_result_DebugDraw3DConfig_set_force_use_camera_from_scene))
                return;
            func_DebugDraw3DConfig_set_force_use_camera_from_scene(inst_ptr, _state);
#endif
        }
    }

    public bool IsForceUseCameraFromScene()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_is_force_use_camera_from_scene", ref func_DebugDraw3DConfig_is_force_use_camera_from_scene, ref func_load_result_DebugDraw3DConfig_is_force_use_camera_from_scene))
            return default;
        return func_DebugDraw3DConfig_is_force_use_camera_from_scene(inst_ptr);
    }

    /// <summary>
    /// Set the visibility layer on which the 3D geometry will be drawn.
    /// Similar to using VisualInstance3D.layers.
    /// </summary>
    public void SetGeometryRenderLayers(int _layers)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_geometry_render_layers", ref func_DebugDraw3DConfig_set_geometry_render_layers, ref func_load_result_DebugDraw3DConfig_set_geometry_render_layers))
                return;
            func_DebugDraw3DConfig_set_geometry_render_layers(inst_ptr, _layers);
#endif
        }
    }

    public int GetGeometryRenderLayers()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_get_geometry_render_layers", ref func_DebugDraw3DConfig_get_geometry_render_layers, ref func_load_result_DebugDraw3DConfig_get_geometry_render_layers))
            return default;
        return func_DebugDraw3DConfig_get_geometry_render_layers(inst_ptr);
    }

    /// <summary>
    /// Set the default color for the collision point of DebugDraw3D.draw_line_hit.
    /// </summary>
    public void SetLineHitColor(Color _new_color)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_line_hit_color", ref func_DebugDraw3DConfig_set_line_hit_color, ref func_load_result_DebugDraw3DConfig_set_line_hit_color))
                return;
            func_DebugDraw3DConfig_set_line_hit_color(inst_ptr, _new_color);
#endif
        }
    }

    public Color GetLineHitColor()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_get_line_hit_color", ref func_DebugDraw3DConfig_get_line_hit_color, ref func_load_result_DebugDraw3DConfig_get_line_hit_color))
            return default;
        return func_DebugDraw3DConfig_get_line_hit_color(inst_ptr);
    }

    /// <summary>
    /// Set the default color for the line after the collision point of DebugDraw3D.draw_line_hit.
    /// </summary>
    public void SetLineAfterHitColor(Color _new_color)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_set_line_after_hit_color", ref func_DebugDraw3DConfig_set_line_after_hit_color, ref func_load_result_DebugDraw3DConfig_set_line_after_hit_color))
                return;
            func_DebugDraw3DConfig_set_line_after_hit_color(inst_ptr, _new_color);
#endif
        }
    }

    public Color GetLineAfterHitColor()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_get_line_after_hit_color", ref func_DebugDraw3DConfig_get_line_after_hit_color, ref func_load_result_DebugDraw3DConfig_get_line_after_hit_color))
            return default;
        return func_DebugDraw3DConfig_get_line_after_hit_color(inst_ptr);
    }

    private static IntPtr Create()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_create", ref func_DebugDraw3DConfig_create, ref func_load_result_DebugDraw3DConfig_create))
            return IntPtr.Zero;
        return func_DebugDraw3DConfig_create();
    }

    private static IntPtr CreateNullptr()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_create_nullptr", ref func_DebugDraw3DConfig_create_nullptr, ref func_load_result_DebugDraw3DConfig_create_nullptr))
            return IntPtr.Zero;
        return func_DebugDraw3DConfig_create_nullptr();
    }

    private static void Destroy(IntPtr inst_ptr)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DConfig_destroy", ref func_DebugDraw3DConfig_destroy, ref func_load_result_DebugDraw3DConfig_destroy))
            return;
        func_DebugDraw3DConfig_destroy(inst_ptr);
    }

}; // class DebugDraw3DConfig

/// <summary>
/// <para>
/// This class is used to override scope parameters for DebugDraw3D.
/// </para>
///
/// `Scope` means that these overridden parameters will affect the drawn geometry until it exits the current scope.
///
/// To create it, use DebugDraw3D.new_scoped_config.
/// Immediately after creation, you can change the values and save the reference in a variable.
///
/// <para>
/// But the main thing is not to save it outside the method or in other objects.
/// After leaving the scope, this object should be deleted.
/// </para>
///
/// ---
/// <para>
/// Also, you can't use scope config between `await`s unless this object is freed before `await`.
/// So, narrow the scope if you want to use `await` and DebugDraw3DScopeConfig in the same method.
/// Or set the value of the variable to `null` so that the object is cleared due to lack of references.
/// <code>
/// # Bad example
/// var _s = DebugDraw3D.new_scoped_config().set_thickness(0.3)
/// DebugDraw3D.draw_box(Vector3.ZERO, Quaternion.IDENTITY, Vector3.ONE)
/// await get_tree().process_frame
/// # your code...
///
/// # Good example
/// if true:
///     var _s = DebugDraw3D.new_scoped_config().set_thickness(0.3)
///     DebugDraw3D.draw_box(Vector3.ZERO, Quaternion.IDENTITY, Vector3.ONE)
/// await get_tree().process_frame
/// # your code...
/// </code>
/// </para>
///
/// ### Examples:
/// <code>
/// var _s = DebugDraw3D.new_scoped_config().set_thickness(0.025).set_center_brightness(0.7)
/// DebugDraw3D.draw_grid_xf(%Grid.global_transform, Vector2i(10,10), Color.LIGHT_GRAY)
/// </code>
///
/// <code>
/// using (var s = DebugDraw3D.NewScopedConfig().SetThickness(0))
///     DebugDraw3D.DrawCameraFrustum(dCamera, Colors.DarkOrange);
/// </code>
/// </summary>
internal class DebugDraw3DScopeConfig : IDisposable
{
    IntPtr inst_ptr;

    public DebugDraw3DScopeConfig(IntPtr inst_ptr)
    {
        this.inst_ptr = inst_ptr;
    }

    public DebugDraw3DScopeConfig(bool instantiate = true)
    {
        this.inst_ptr = instantiate ? Create() : CreateNullptr();
    }

    ~DebugDraw3DScopeConfig() => Dispose();

    public static explicit operator IntPtr(DebugDraw3DScopeConfig o) { return o.inst_ptr; }

    public void Dispose()
    {
        if (inst_ptr != IntPtr.Zero)
        {
            Destroy(inst_ptr);
            inst_ptr = IntPtr.Zero;
        }
    }

    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_thickness_selfreturn(IntPtr inst_ptr, real_t _value);
    static dlgt_DebugDraw3DScopeConfig_set_thickness_selfreturn func_DebugDraw3DScopeConfig_set_thickness_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_thickness_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate real_t dlgt_DebugDraw3DScopeConfig_get_thickness(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_thickness func_DebugDraw3DScopeConfig_get_thickness; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_thickness;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_center_brightness_selfreturn(IntPtr inst_ptr, real_t _value);
    static dlgt_DebugDraw3DScopeConfig_set_center_brightness_selfreturn func_DebugDraw3DScopeConfig_set_center_brightness_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_center_brightness_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate real_t dlgt_DebugDraw3DScopeConfig_get_center_brightness(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_center_brightness func_DebugDraw3DScopeConfig_get_center_brightness; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_center_brightness;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn(IntPtr inst_ptr, bool _value);
    static dlgt_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn func_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DScopeConfig_is_hd_sphere(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_is_hd_sphere func_DebugDraw3DScopeConfig_is_hd_sphere; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_is_hd_sphere;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_plane_size_selfreturn(IntPtr inst_ptr, real_t _value);
    static dlgt_DebugDraw3DScopeConfig_set_plane_size_selfreturn func_DebugDraw3DScopeConfig_set_plane_size_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_plane_size_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate real_t dlgt_DebugDraw3DScopeConfig_get_plane_size(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_plane_size func_DebugDraw3DScopeConfig_get_plane_size; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_plane_size;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_transform_selfreturn(IntPtr inst_ptr, Transform3D _value);
    static dlgt_DebugDraw3DScopeConfig_set_transform_selfreturn func_DebugDraw3DScopeConfig_set_transform_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_transform_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Transform3D dlgt_DebugDraw3DScopeConfig_get_transform(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_transform func_DebugDraw3DScopeConfig_get_transform; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_transform;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn(IntPtr inst_ptr, Color _value);
    static dlgt_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn func_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate Color dlgt_DebugDraw3DScopeConfig_get_text_outline_color(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_text_outline_color func_DebugDraw3DScopeConfig_get_text_outline_color; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_text_outline_color;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn(IntPtr inst_ptr, int _value);
    static dlgt_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn func_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int dlgt_DebugDraw3DScopeConfig_get_text_outline_size(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_text_outline_size func_DebugDraw3DScopeConfig_get_text_outline_size; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_text_outline_size;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn(IntPtr inst_ptr, bool _value);
    static dlgt_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn func_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DScopeConfig_get_text_fixed_size(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_text_fixed_size func_DebugDraw3DScopeConfig_get_text_fixed_size; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_text_fixed_size;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_text_font_selfreturn(IntPtr inst_ptr, ulong _value);
    static dlgt_DebugDraw3DScopeConfig_set_text_font_selfreturn func_DebugDraw3DScopeConfig_set_text_font_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_text_font_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate ulong dlgt_DebugDraw3DScopeConfig_get_text_font(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_text_font func_DebugDraw3DScopeConfig_get_text_font; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_text_font;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_viewport_selfreturn(IntPtr inst_ptr, ulong /*godot::Viewport*/ _value);
    static dlgt_DebugDraw3DScopeConfig_set_viewport_selfreturn func_DebugDraw3DScopeConfig_set_viewport_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_viewport_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate ulong dlgt_DebugDraw3DScopeConfig_get_viewport(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_get_viewport func_DebugDraw3DScopeConfig_get_viewport; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_get_viewport;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn(IntPtr inst_ptr, bool _value);
    static dlgt_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn func_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3DScopeConfig_is_no_depth_test(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_is_no_depth_test func_DebugDraw3DScopeConfig_is_no_depth_test; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_is_no_depth_test;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DScopeConfig_create();
    static dlgt_DebugDraw3DScopeConfig_create func_DebugDraw3DScopeConfig_create; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_create;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DScopeConfig_create_nullptr();
    static dlgt_DebugDraw3DScopeConfig_create_nullptr func_DebugDraw3DScopeConfig_create_nullptr; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_create_nullptr;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DScopeConfig_destroy(IntPtr inst_ptr);
    static dlgt_DebugDraw3DScopeConfig_destroy func_DebugDraw3DScopeConfig_destroy; static DD3DFuncLoadingResult func_load_result_DebugDraw3DScopeConfig_destroy;

    /// <summary>
    /// Set the thickness of the volumetric lines. If the value is 0, the standard wireframe rendering will be used.
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetThickness(real_t _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_thickness_selfreturn", ref func_DebugDraw3DScopeConfig_set_thickness_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_thickness_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_thickness_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public real_t GetThickness()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_thickness", ref func_DebugDraw3DScopeConfig_get_thickness, ref func_load_result_DebugDraw3DScopeConfig_get_thickness))
                return default;
            return func_DebugDraw3DScopeConfig_get_thickness(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the brightness of the central part of the volumetric lines.
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetCenterBrightness(real_t _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_center_brightness_selfreturn", ref func_DebugDraw3DScopeConfig_set_center_brightness_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_center_brightness_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_center_brightness_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public real_t GetCenterBrightness()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_center_brightness", ref func_DebugDraw3DScopeConfig_get_center_brightness, ref func_load_result_DebugDraw3DScopeConfig_get_center_brightness))
                return default;
            return func_DebugDraw3DScopeConfig_get_center_brightness(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the mesh density of the sphere
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetHdSphere(bool _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_hd_sphere_selfreturn", ref func_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_hd_sphere_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public bool IsHdSphere()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_is_hd_sphere", ref func_DebugDraw3DScopeConfig_is_hd_sphere, ref func_load_result_DebugDraw3DScopeConfig_is_hd_sphere))
                return default;
            return func_DebugDraw3DScopeConfig_is_hd_sphere(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the size of the `Plane` in DebugDraw3D.draw_plane. If set to `INF`, the `Far` parameter of the current camera will be used.
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetPlaneSize(real_t _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_plane_size_selfreturn", ref func_DebugDraw3DScopeConfig_set_plane_size_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_plane_size_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_plane_size_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public real_t GetPlaneSize()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_plane_size", ref func_DebugDraw3DScopeConfig_get_plane_size, ref func_load_result_DebugDraw3DScopeConfig_get_plane_size))
                return default;
            return func_DebugDraw3DScopeConfig_get_plane_size(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the base/local `transform` relative to which the shapes will be drawn.
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetTransform(Transform3D _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_transform_selfreturn", ref func_DebugDraw3DScopeConfig_set_transform_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_transform_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_transform_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public Transform3D GetTransform()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_transform", ref func_DebugDraw3DScopeConfig_get_transform, ref func_load_result_DebugDraw3DScopeConfig_get_transform))
                return default;
            return func_DebugDraw3DScopeConfig_get_transform(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the `outline` color in DebugDraw3D.draw_text.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// Frequent unsystematic changes to this property can lead to significant performance degradation.
    /// </para>
    /// </summary>
    public DebugDraw3DScopeConfig SetTextOutlineColor(Color _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_text_outline_color_selfreturn", ref func_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_text_outline_color_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public Color GetTextOutlineColor()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_text_outline_color", ref func_DebugDraw3DScopeConfig_get_text_outline_color, ref func_load_result_DebugDraw3DScopeConfig_get_text_outline_color))
                return default;
            return func_DebugDraw3DScopeConfig_get_text_outline_color(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the size of the `outline` in DebugDraw3D.draw_text.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// Frequent unsystematic changes to this property can lead to significant performance degradation.
    /// </para>
    /// </summary>
    public DebugDraw3DScopeConfig SetTextOutlineSize(int _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_text_outline_size_selfreturn", ref func_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_text_outline_size_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public int GetTextOutlineSize()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_text_outline_size", ref func_DebugDraw3DScopeConfig_get_text_outline_size, ref func_load_result_DebugDraw3DScopeConfig_get_text_outline_size))
                return default;
            return func_DebugDraw3DScopeConfig_get_text_outline_size(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Makes the text in DebugDraw3D.draw_text the same size regardless of distance.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// Frequent unsystematic changes to this property can lead to significant performance degradation.
    /// </para>
    /// </summary>
    public DebugDraw3DScopeConfig SetTextFixedSize(bool _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn", ref func_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_text_fixed_size_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public bool GetTextFixedSize()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_text_fixed_size", ref func_DebugDraw3DScopeConfig_get_text_fixed_size, ref func_load_result_DebugDraw3DScopeConfig_get_text_fixed_size))
                return default;
            return func_DebugDraw3DScopeConfig_get_text_fixed_size(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set the font of the text in DebugDraw3D.draw_text.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// Frequent unsystematic changes to this property can lead to significant performance degradation.
    /// </para>
    /// </summary>
    public DebugDraw3DScopeConfig SetTextFont(Font _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_text_font_selfreturn", ref func_DebugDraw3DScopeConfig_set_text_font_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_text_font_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_text_font_selfreturn(inst_ptr, _value != null ? _value.GetInstanceId() : 0);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public Font GetTextFont()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_text_font", ref func_DebugDraw3DScopeConfig_get_text_font, ref func_load_result_DebugDraw3DScopeConfig_get_text_font))
                return default;
            return (Font)GodotObject.InstanceFromId(func_DebugDraw3DScopeConfig_get_text_font(inst_ptr));
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set which Viewport will be used to get World3D.
    ///
    /// If the World3D of this Viewport has not been used before,
    /// then the owner of this World3D will be found in the current branch of the tree,
    /// and special observer nodes will be added to it.
    ///
    /// <para>
    /// Objects created for a specific Viewport will use only one camera related to that Viewport for culling.
    /// </para>
    /// </summary>
    public DebugDraw3DScopeConfig SetViewport(Viewport _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_viewport_selfreturn", ref func_DebugDraw3DScopeConfig_set_viewport_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_viewport_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_viewport_selfreturn(inst_ptr, _value != null ? _value.GetInstanceId() : 0);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public Viewport GetViewport()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_get_viewport", ref func_DebugDraw3DScopeConfig_get_viewport, ref func_load_result_DebugDraw3DScopeConfig_get_viewport))
                return default;
            return (Viewport)GodotObject.InstanceFromId(func_DebugDraw3DScopeConfig_get_viewport(inst_ptr));
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    /// <summary>
    /// Set whether the `depth_test_disabled` flag is added or not in the shaders of the debug shapes.
    ///
    /// <para>
    /// It may cause artifacts when drawing volumetric objects.
    /// </para>
    ///
    /// [THERE WAS AN IMAGE]
    /// </summary>
    public DebugDraw3DScopeConfig SetNoDepthTest(bool _value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_set_no_depth_test_selfreturn", ref func_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn, ref func_load_result_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn))
                return this;
            func_DebugDraw3DScopeConfig_set_no_depth_test_selfreturn(inst_ptr, _value);
            return this;
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return this;
#endif
    }

    public bool IsNoDepthTest()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_is_no_depth_test", ref func_DebugDraw3DScopeConfig_is_no_depth_test, ref func_load_result_DebugDraw3DScopeConfig_is_no_depth_test))
                return default;
            return func_DebugDraw3DScopeConfig_is_no_depth_test(inst_ptr);
#endif
        }
#if _DD3D_RUNTIME_CHECK_ENABLED
        return default;
#endif
    }

    private static IntPtr Create()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_create", ref func_DebugDraw3DScopeConfig_create, ref func_load_result_DebugDraw3DScopeConfig_create))
            return IntPtr.Zero;
        return func_DebugDraw3DScopeConfig_create();
    }

    private static IntPtr CreateNullptr()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_create_nullptr", ref func_DebugDraw3DScopeConfig_create_nullptr, ref func_load_result_DebugDraw3DScopeConfig_create_nullptr))
            return IntPtr.Zero;
        return func_DebugDraw3DScopeConfig_create_nullptr();
    }

    private static void Destroy(IntPtr inst_ptr)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DScopeConfig_destroy", ref func_DebugDraw3DScopeConfig_destroy, ref func_load_result_DebugDraw3DScopeConfig_destroy))
            return;
        func_DebugDraw3DScopeConfig_destroy(inst_ptr);
    }

}; // class DebugDraw3DScopeConfig

/// <summary>
/// <para>
/// Singleton class for calling debugging 3D methods.
/// </para>
///
/// You can use the project settings `debug_draw_3d/settings/3d` for additional customization.
///
/// For example, `add_bevel_to_volumetric_geometry` allows you to remove or add a bevel for volumetric lines.
///
/// [THERE WAS AN IMAGE]
///
/// `use_icosphere` and `use_icosphere_for_hd` allow you to change the sphere mesh.
///
/// [THERE WAS AN IMAGE]
///
/// <para>
/// Wireframe shapes and volumetric wireframes do not support translucency to avoid overlap issues and for better performance.
/// At this point, you can use translucency when drawing planes DebugDraw3D.draw_plane.
/// </para>
///
/// ---
/// <para>
/// Objects created in `_physics_process` are processed separately from those created in `_process`,
/// so they will be deleted only in the first physics tick after rendering.
/// This allows to display objects even if several frames passed between physics ticks.
/// </para>
///
/// ---
/// <para>
/// You can use this class anywhere, including in `_physics_process` and `_process` (and probably from other threads).
/// It is worth mentioning that physics ticks may not be called every frame or may be called several times in one frame.
/// So if you want to avoid multiple identical `draw_` calls, you can call `draw_` methods in `_process` or use such a check:
/// <code>
/// var physics_tick_processed := false
/// func _process(delta: float) -> void:
///     # Reset after rendering frame
///     physics_tick_processed = false
///     # some logic
///
/// func _physics_process(delta: float) -> void:
///     if not physics_tick_processed:
///         physics_tick_processed = true
///         # some DD3D logic
/// </code>
/// </para>
///
/// ---
/// <para>
/// Due to the way Godot registers this addon, it is not possible to use the `draw_` methods
/// in the first few frames immediately after the project is launched.
/// </para>
/// </summary>
internal static class DebugDraw3D
{
    public enum PointType : uint
    {
        TypeSquare = 0,
        TypeSphere = 1,
    }

    /// <summary>
    /// Set the configuration global for everything in DebugDraw3D.
    /// </summary>
    public static DebugDraw3DConfig Config { get => GetConfig(); set => SetConfig(value); }

    /// <summary>
    /// Set whether debug drawing works or not.
    /// </summary>
    public static bool DebugEnabled { get => IsDebugEnabled(); set => SetDebugEnabled(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3D_new_scoped_config();
    static dlgt_DebugDraw3D_new_scoped_config func_DebugDraw3D_new_scoped_config; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_new_scoped_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3D_scoped_config();
    static dlgt_DebugDraw3D_scoped_config func_DebugDraw3D_scoped_config; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_scoped_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_set_config(IntPtr cfg);
    static dlgt_DebugDraw3D_set_config func_DebugDraw3D_set_config; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_set_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3D_get_config();
    static dlgt_DebugDraw3D_get_config func_DebugDraw3D_get_config; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_get_config;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_set_debug_enabled(bool state);
    static dlgt_DebugDraw3D_set_debug_enabled func_DebugDraw3D_set_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_set_debug_enabled;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDraw3D_is_debug_enabled();
    static dlgt_DebugDraw3D_is_debug_enabled func_DebugDraw3D_is_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_is_debug_enabled;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3D_get_render_stats();
    static dlgt_DebugDraw3D_get_render_stats func_DebugDraw3D_get_render_stats; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_get_render_stats;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3D_get_render_stats_for_world(ulong /*godot::Viewport*/ viewport);
    static dlgt_DebugDraw3D_get_render_stats_for_world func_DebugDraw3D_get_render_stats_for_world; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_get_render_stats_for_world;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_regenerate_geometry_meshes();
    static dlgt_DebugDraw3D_regenerate_geometry_meshes func_DebugDraw3D_regenerate_geometry_meshes; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_regenerate_geometry_meshes;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_clear_all();
    static dlgt_DebugDraw3D_clear_all func_DebugDraw3D_clear_all; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_clear_all;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_sphere(Vector3 position, real_t radius, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_sphere func_DebugDraw3D_draw_sphere; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_sphere;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_sphere_xf(Transform3D transform, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_sphere_xf func_DebugDraw3D_draw_sphere_xf; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_sphere_xf;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_capsule(Vector3 position, Quaternion rotation, real_t radius, real_t height, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_capsule func_DebugDraw3D_draw_capsule; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_capsule;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_capsule_ab(Vector3 a, Vector3 b, real_t radius, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_capsule_ab func_DebugDraw3D_draw_capsule_ab; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_capsule_ab;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_cylinder(Transform3D transform, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_cylinder func_DebugDraw3D_draw_cylinder; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_cylinder;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_cylinder_ab(Vector3 a, Vector3 b, real_t radius, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_cylinder_ab func_DebugDraw3D_draw_cylinder_ab; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_cylinder_ab;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_box(Vector3 position, Quaternion rotation, Vector3 size, Color color, bool is_box_centered, real_t duration);
    static dlgt_DebugDraw3D_draw_box func_DebugDraw3D_draw_box; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_box;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_box_ab(Vector3 a, Vector3 b, Vector3 up, Color color, bool is_ab_diagonal, real_t duration);
    static dlgt_DebugDraw3D_draw_box_ab func_DebugDraw3D_draw_box_ab; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_box_ab;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_box_xf(Transform3D transform, Color color, bool is_box_centered, real_t duration);
    static dlgt_DebugDraw3D_draw_box_xf func_DebugDraw3D_draw_box_xf; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_box_xf;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_aabb(Aabb aabb, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_aabb func_DebugDraw3D_draw_aabb; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_aabb;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_aabb_ab(Vector3 a, Vector3 b, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_aabb_ab func_DebugDraw3D_draw_aabb_ab; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_aabb_ab;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_line_hit(Vector3 start, Vector3 end, Vector3 hit, bool is_hit, real_t hit_size, Color hit_color, Color after_hit_color, real_t duration);
    static dlgt_DebugDraw3D_draw_line_hit func_DebugDraw3D_draw_line_hit; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_line_hit;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_line_hit_offset(Vector3 start, Vector3 end, bool is_hit, real_t unit_offset_of_hit, real_t hit_size, Color hit_color, Color after_hit_color, real_t duration);
    static dlgt_DebugDraw3D_draw_line_hit_offset func_DebugDraw3D_draw_line_hit_offset; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_line_hit_offset;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_line(Vector3 a, Vector3 b, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_line func_DebugDraw3D_draw_line; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_line;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_ray(Vector3 origin, Vector3 direction, real_t length, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_ray func_DebugDraw3D_draw_ray; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_ray;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_lines_c(IntPtr /*godot::PackedVector3Array*/ lines_data, ulong lines_size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_lines_c func_DebugDraw3D_draw_lines_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_lines_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_line_path_c(IntPtr /*godot::PackedVector3Array*/ path_data, ulong path_size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_line_path_c func_DebugDraw3D_draw_line_path_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_line_path_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_arrowhead(Transform3D transform, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_arrowhead func_DebugDraw3D_draw_arrowhead; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_arrowhead;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_arrow(Vector3 a, Vector3 b, Color color, real_t arrow_size, bool is_absolute_size, real_t duration);
    static dlgt_DebugDraw3D_draw_arrow func_DebugDraw3D_draw_arrow; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_arrow;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_arrow_ray(Vector3 origin, Vector3 direction, real_t length, Color color, real_t arrow_size, bool is_absolute_size, real_t duration);
    static dlgt_DebugDraw3D_draw_arrow_ray func_DebugDraw3D_draw_arrow_ray; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_arrow_ray;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_arrow_path_c(IntPtr /*godot::PackedVector3Array*/ path_data, ulong path_size, Color color, real_t arrow_size, bool is_absolute_size, real_t duration);
    static dlgt_DebugDraw3D_draw_arrow_path_c func_DebugDraw3D_draw_arrow_path_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_arrow_path_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_point_path_c(IntPtr /*godot::PackedVector3Array*/ path_data, ulong path_size, uint /*DebugDraw3D::PointType*/ type, real_t size, Color points_color, Color lines_color, real_t duration);
    static dlgt_DebugDraw3D_draw_point_path_c func_DebugDraw3D_draw_point_path_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_point_path_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_points_c(IntPtr /*godot::PackedVector3Array*/ points_data, ulong points_size, uint /*DebugDraw3D::PointType*/ type, real_t size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_points_c func_DebugDraw3D_draw_points_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_points_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_square(Vector3 position, real_t size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_square func_DebugDraw3D_draw_square; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_square;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_plane(Plane plane, Color color, Vector3 anchor_point, real_t duration);
    static dlgt_DebugDraw3D_draw_plane func_DebugDraw3D_draw_plane; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_plane;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_position(Transform3D transform, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_position func_DebugDraw3D_draw_position; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_position;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_gizmo(Transform3D transform, Color color, bool is_centered, real_t duration);
    static dlgt_DebugDraw3D_draw_gizmo func_DebugDraw3D_draw_gizmo; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_gizmo;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_grid(Vector3 origin, Vector3 x_size, Vector3 y_size, Vector2I subdivision, Color color, bool is_centered, real_t duration);
    static dlgt_DebugDraw3D_draw_grid func_DebugDraw3D_draw_grid; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_grid;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_grid_xf(Transform3D transform, Vector2I p_subdivision, Color color, bool is_centered, real_t duration);
    static dlgt_DebugDraw3D_draw_grid_xf func_DebugDraw3D_draw_grid_xf; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_grid_xf;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_camera_frustum(ulong /*godot::Camera3D*/ camera, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_camera_frustum func_DebugDraw3D_draw_camera_frustum; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_camera_frustum;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_camera_frustum_planes_c(IntPtr /*const godot::Plane **/ camera_frustum_data, ulong camera_frustum_size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_camera_frustum_planes_c func_DebugDraw3D_draw_camera_frustum_planes_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_camera_frustum_planes_c;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3D_draw_text_c(Vector3 position, [MarshalAs(UnmanagedType.LPUTF8Str)] string /*godot::String*/ text_string, int size, Color color, real_t duration);
    static dlgt_DebugDraw3D_draw_text_c func_DebugDraw3D_draw_text_c; static DD3DFuncLoadingResult func_load_result_DebugDraw3D_draw_text_c;

    /// <summary>
    /// Create a new DebugDraw3DScopeConfig instance and register it.
    ///
    /// This class allows you to override some parameters within scope for the following `draw_*` calls.
    ///
    /// Store this instance in a local variable inside the method.
    /// </summary>
    public static DebugDraw3DScopeConfig NewScopedConfig()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_new_scoped_config", ref func_DebugDraw3D_new_scoped_config, ref func_load_result_DebugDraw3D_new_scoped_config))
            return null;
        return new DebugDraw3DScopeConfig(func_DebugDraw3D_new_scoped_config());
    }

    /// <summary>
    /// Returns the default scope settings that will be applied at the start of each new frame.
    ///
    /// Default values can be overridden in the project settings `debug_draw_3d/settings/3d/volumetric_defaults`.
    ///
    /// <para>
    /// When used in a managed language, this is not mandatory, but it is recommended to finish the `scoped_config()` configuration with a dispose.
    /// This will reduce the number of objects awaiting removal by the garbage collector.
    /// <code>
    /// DebugDraw3D.ScopedConfig().SetThickness(debug_thickness).Dispose();
    /// </code>
    /// </para>
    /// </summary>
    public static DebugDraw3DScopeConfig ScopedConfig()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_scoped_config", ref func_DebugDraw3D_scoped_config, ref func_load_result_DebugDraw3D_scoped_config))
            return null;
        return new DebugDraw3DScopeConfig(func_DebugDraw3D_scoped_config());
    }

    /// <summary>
    /// Set the configuration global for everything in DebugDraw3D.
    /// </summary>
    public static void SetConfig(DebugDraw3DConfig cfg)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_set_config", ref func_DebugDraw3D_set_config, ref func_load_result_DebugDraw3D_set_config))
                return;
            func_DebugDraw3D_set_config((IntPtr)cfg);
#endif
        }
    }

    /// <summary>
    /// Get the DebugDraw3DConfig.
    /// </summary>
    public static DebugDraw3DConfig GetConfig()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_get_config", ref func_DebugDraw3D_get_config, ref func_load_result_DebugDraw3D_get_config))
            return null;
        return new DebugDraw3DConfig(func_DebugDraw3D_get_config());
    }

    /// <summary>
    /// Set whether debug drawing works or not.
    /// </summary>
    public static void SetDebugEnabled(bool state)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_set_debug_enabled", ref func_DebugDraw3D_set_debug_enabled, ref func_load_result_DebugDraw3D_set_debug_enabled))
                return;
            func_DebugDraw3D_set_debug_enabled(state);
#endif
        }
    }

    public static bool IsDebugEnabled()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_is_debug_enabled", ref func_DebugDraw3D_is_debug_enabled, ref func_load_result_DebugDraw3D_is_debug_enabled))
            return default;
        return func_DebugDraw3D_is_debug_enabled();
    }

    /// <summary>
    /// Returns an instance of DebugDraw3DStats with the current statistics.
    ///
    /// Some data can be delayed by 1 frame.
    /// </summary>
    public static DebugDraw3DStats GetRenderStats()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_get_render_stats", ref func_DebugDraw3D_get_render_stats, ref func_load_result_DebugDraw3D_get_render_stats))
            return null;
        return new DebugDraw3DStats(func_DebugDraw3D_get_render_stats());
    }

    /// <summary>
    /// Returns an instance of DebugDraw3DStats with the current statistics for the World3D of the Viewport.
    ///
    /// Some data can be delayed by 1 frame.
    /// </summary>
    public static DebugDraw3DStats GetRenderStatsForWorld(Viewport viewport)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_get_render_stats_for_world", ref func_DebugDraw3D_get_render_stats_for_world, ref func_load_result_DebugDraw3D_get_render_stats_for_world))
            return null;
        return new DebugDraw3DStats(func_DebugDraw3D_get_render_stats_for_world(viewport != null ? viewport.GetInstanceId() : 0));
    }

    /// <summary>
    /// Regenerate meshes.
    ///
    /// Can be useful if you want to change some project settings and not restart the project.
    /// </summary>
    public static void RegenerateGeometryMeshes()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_regenerate_geometry_meshes", ref func_DebugDraw3D_regenerate_geometry_meshes, ref func_load_result_DebugDraw3D_regenerate_geometry_meshes))
                return;
            func_DebugDraw3D_regenerate_geometry_meshes();
#endif
        }
    }

    /// <summary>
    /// Clear all 3D geometry
    /// </summary>
    public static void ClearAll()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_clear_all", ref func_DebugDraw3D_clear_all, ref func_load_result_DebugDraw3D_clear_all))
                return;
            func_DebugDraw3D_clear_all();
#endif
        }
    }

    /// <summary>
    /// Draw a sphere
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="position">Center of the sphere</param>
    /// <param name="radius">Sphere radius</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawSphere(Vector3 position, real_t radius = 0.5f, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_sphere", ref func_DebugDraw3D_draw_sphere, ref func_load_result_DebugDraw3D_draw_sphere))
                return;
            func_DebugDraw3D_draw_sphere(position, radius, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a sphere with a radius of 0.5
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="transform">Sphere transform</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawSphereXf(Transform3D transform, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_sphere_xf", ref func_DebugDraw3D_draw_sphere_xf, ref func_load_result_DebugDraw3D_draw_sphere_xf))
                return;
            func_DebugDraw3D_draw_sphere_xf(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a vertical capsule
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// A capsule will not be displayed if the height or radius is approximately equal to or less than zero.
    /// </para>
    ///
    /// ---
    /// <para>
    /// If you need to apply additional transformations, you can use DebugDraw3DScopeConfig.set_transform.
    /// </para>
    ///
    /// </summary>
    /// <param name="position">Capsule position</param>
    /// <param name="rotation">Capsule rotation</param>
    /// <param name="radius">Capsule radius</param>
    /// <param name="height">Capsule height including caps. Based on this value, the actual radius of the capsule will be calculated.</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCapsule(Vector3 position, Quaternion rotation, real_t radius, real_t height, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_capsule", ref func_DebugDraw3D_draw_capsule, ref func_load_result_DebugDraw3D_draw_capsule))
                return;
            func_DebugDraw3D_draw_capsule(position, rotation, radius, height, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a capsule between points A and B with the desired radius.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// A capsule will not be displayed if the distance between points A and B or the radius is approximately equal to or less than zero.
    /// </para>
    ///
    /// </summary>
    /// <param name="a">First pole of the capsule</param>
    /// <param name="b">Second pole of the capsule</param>
    /// <param name="radius">Capsule radius</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCapsuleAb(Vector3 a, Vector3 b, real_t radius = 0.5f, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_capsule_ab", ref func_DebugDraw3D_draw_capsule_ab, ref func_load_result_DebugDraw3D_draw_capsule_ab))
                return;
            func_DebugDraw3D_draw_capsule_ab(a, b, radius, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a vertical cylinder with radius 1.0 (x, z) and height 1.0 (y)
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="transform">Cylinder transform</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCylinder(Transform3D transform, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_cylinder", ref func_DebugDraw3D_draw_cylinder, ref func_load_result_DebugDraw3D_draw_cylinder))
                return;
            func_DebugDraw3D_draw_cylinder(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a cylinder between points A and B with a certain radius.
    ///
    /// <para>
    /// A cylinder will not be displayed if the distance between points A and B is approximately zero.
    /// </para>
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="a">Bottom point of the Cylinder</param>
    /// <param name="b">Top point of the Cylinder</param>
    /// <param name="radius">Cylinder radius</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCylinderAb(Vector3 a, Vector3 b, real_t radius = 0.5f, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_cylinder_ab", ref func_DebugDraw3D_draw_cylinder_ab, ref func_load_result_DebugDraw3D_draw_cylinder_ab))
                return;
            func_DebugDraw3D_draw_cylinder_ab(a, b, radius, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a box
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="position">Position of the Box</param>
    /// <param name="rotation">Rotation of the box</param>
    /// <param name="size">Size of the Box</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_box_centered">Set where the center of the box will be. In the center or in the bottom corner</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawBox(Vector3 position, Quaternion rotation, Vector3 size, Color? color = null, bool is_box_centered = false, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_box", ref func_DebugDraw3D_draw_box, ref func_load_result_DebugDraw3D_draw_box))
                return;
            func_DebugDraw3D_draw_box(position, rotation, size, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_box_centered, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a box between points A and B by rotating and scaling based on the up vector
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// A box will not be displayed if its dimensions are close to zero or if the up vector is approximately zero.
    /// </para>
    ///
    /// </summary>
    /// <param name="a">Start position</param>
    /// <param name="b">End position</param>
    /// <param name="up">Vertical vector by which the box will be aligned</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_ab_diagonal">Set uses the diagonal between the corners or the diagonal between the centers of two edges</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawBoxAb(Vector3 a, Vector3 b, Vector3 up, Color? color = null, bool is_ab_diagonal = true, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_box_ab", ref func_DebugDraw3D_draw_box_ab, ref func_load_result_DebugDraw3D_draw_box_ab))
                return;
            func_DebugDraw3D_draw_box_ab(a, b, up, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_ab_diagonal, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a box as in DebugDraw3D.draw_box
    ///
    /// </summary>
    /// <param name="transform">Box transform</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_box_centered">Set where the center of the box will be. In the center or in the bottom corner</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawBoxXf(Transform3D transform, Color? color = null, bool is_box_centered = true, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_box_xf", ref func_DebugDraw3D_draw_box_xf, ref func_load_result_DebugDraw3D_draw_box_xf))
                return;
            func_DebugDraw3D_draw_box_xf(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_box_centered, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a box as in DebugDraw3D.draw_box, but based on the AABB
    ///
    /// </summary>
    /// <param name="aabb">AABB</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawAabb(Aabb aabb, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_aabb", ref func_DebugDraw3D_draw_aabb, ref func_load_result_DebugDraw3D_draw_aabb))
                return;
            func_DebugDraw3D_draw_aabb(aabb, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw the box as in DebugDraw3D.draw_aabb, but AABB is defined by the diagonal AB
    ///
    /// </summary>
    /// <param name="a">Start position</param>
    /// <param name="b">End position</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawAabbAb(Vector3 a, Vector3 b, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_aabb_ab", ref func_DebugDraw3D_draw_aabb_ab, ref func_load_result_DebugDraw3D_draw_aabb_ab))
                return;
            func_DebugDraw3D_draw_aabb_ab(a, b, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw line separated by hit point (billboard square) or not separated if `is_hit = false`.
    ///
    /// Some of the default settings can be overridden in DebugDraw3DConfig.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="start">Start point</param>
    /// <param name="end">End point</param>
    /// <param name="hit">Hit point</param>
    /// <param name="is_hit">Whether to draw the collision point</param>
    /// <param name="hit_size">Size of the hit point</param>
    /// <param name="hit_color">Color of the hit point and line before hit</param>
    /// <param name="after_hit_color">Color of line after hit position</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawLineHit(Vector3 start, Vector3 end, Vector3 hit, bool is_hit, real_t hit_size = 0.25f, Color? hit_color = null, Color? after_hit_color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_line_hit", ref func_DebugDraw3D_draw_line_hit, ref func_load_result_DebugDraw3D_draw_line_hit))
                return;
            func_DebugDraw3D_draw_line_hit(start, end, hit, is_hit, hit_size, hit_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, after_hit_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw line separated by hit point.
    ///
    /// Similar to DebugDraw3D.draw_line_hit, but instead of a hit point, an offset from the start point is used.
    ///
    /// Some of the default settings can be overridden in DebugDraw3DConfig.
    ///
    /// </summary>
    /// <param name="start">Start point</param>
    /// <param name="end">End point</param>
    /// <param name="is_hit">Whether to draw the collision point</param>
    /// <param name="unit_offset_of_hit">Unit offset on the line where the collision occurs</param>
    /// <param name="hit_size">Size of the hit point</param>
    /// <param name="hit_color">Color of the hit point and line before hit</param>
    /// <param name="after_hit_color">Color of line after hit position</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawLineHitOffset(Vector3 start, Vector3 end, bool is_hit, real_t unit_offset_of_hit = 0.5f, real_t hit_size = 0.25f, Color? hit_color = null, Color? after_hit_color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_line_hit_offset", ref func_DebugDraw3D_draw_line_hit_offset, ref func_load_result_DebugDraw3D_draw_line_hit_offset))
                return;
            func_DebugDraw3D_draw_line_hit_offset(start, end, is_hit, unit_offset_of_hit, hit_size, hit_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, after_hit_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a single line
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="a">Start point</param>
    /// <param name="b">End point</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawLine(Vector3 a, Vector3 b, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_line", ref func_DebugDraw3D_draw_line, ref func_load_result_DebugDraw3D_draw_line))
                return;
            func_DebugDraw3D_draw_line(a, b, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a ray.
    ///
    /// Same as DebugDraw3D.draw_line, but uses origin, direction and length instead of A and B.
    ///
    /// </summary>
    /// <param name="origin">Origin</param>
    /// <param name="direction">Direction</param>
    /// <param name="length">Length</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawRay(Vector3 origin, Vector3 direction, real_t length, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_ray", ref func_DebugDraw3D_draw_ray, ref func_load_result_DebugDraw3D_draw_ray))
                return;
            func_DebugDraw3D_draw_ray(origin, direction, length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw an array of lines. Each line is two points, so the array must be of even size.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="lines">An array of points of lines. 1 line = 2 vectors3. The array size must be even.</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawLines(Vector3[] lines, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_lines_c", ref func_DebugDraw3D_draw_lines_c, ref func_load_result_DebugDraw3D_draw_lines_c))
                return;

            var lines_native_fixed = GCHandle.Alloc(lines, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_lines_c(lines_native_fixed.AddrOfPinnedObject(), (ulong)lines.Length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
            }
            finally
            {
                lines_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw an array of lines.
    ///
    /// Unlike DebugDraw3D.draw_lines, here lines are drawn between each point in the array.
    ///
    /// The array can be of any size.
    ///
    /// <para>
    /// If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
    /// </para>
    ///
    /// </summary>
    /// <param name="path">Sequence of points</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawLinePath(Vector3[] path, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_line_path_c", ref func_DebugDraw3D_draw_line_path_c, ref func_load_result_DebugDraw3D_draw_line_path_c))
                return;

            var path_native_fixed = GCHandle.Alloc(path, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_line_path_c(path_native_fixed.AddrOfPinnedObject(), (ulong)path.Length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
            }
            finally
            {
                path_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw the arrowhead
    ///
    /// </summary>
    /// <param name="transform">godot::Transform3D of the Arrowhead</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawArrowhead(Transform3D transform, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_arrowhead", ref func_DebugDraw3D_draw_arrowhead, ref func_load_result_DebugDraw3D_draw_arrowhead))
                return;
            func_DebugDraw3D_draw_arrowhead(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw line with arrowhead
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// An arrow will not be displayed if the distance between points a and b is approximately zero.
    /// </para>
    ///
    /// </summary>
    /// <param name="a">Start point</param>
    /// <param name="b">End point</param>
    /// <param name="color">Primary color</param>
    /// <param name="arrow_size">Size of the arrow</param>
    /// <param name="is_absolute_size">Is `arrow_size` absolute or relative to the length of the string?</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawArrow(Vector3 a, Vector3 b, Color? color = null, real_t arrow_size = 0.5f, bool is_absolute_size = false, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_arrow", ref func_DebugDraw3D_draw_arrow, ref func_load_result_DebugDraw3D_draw_arrow))
                return;
            func_DebugDraw3D_draw_arrow(a, b, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, arrow_size, is_absolute_size, duration);
#endif
        }
    }

    /// <summary>
    /// Same as DebugDraw3D.draw_arrow, but uses origin, direction and length instead of A and B.
    ///
    /// </summary>
    /// <param name="origin">Origin</param>
    /// <param name="direction">Direction</param>
    /// <param name="length">Length</param>
    /// <param name="color">Primary color</param>
    /// <param name="arrow_size">Size of the arrow</param>
    /// <param name="is_absolute_size">Is `arrow_size` absolute or relative to the line length?</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawArrowRay(Vector3 origin, Vector3 direction, real_t length, Color? color = null, real_t arrow_size = 0.5f, bool is_absolute_size = false, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_arrow_ray", ref func_DebugDraw3D_draw_arrow_ray, ref func_load_result_DebugDraw3D_draw_arrow_ray))
                return;
            func_DebugDraw3D_draw_arrow_ray(origin, direction, length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, arrow_size, is_absolute_size, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a sequence of points connected by lines with arrows like DebugDraw3D.draw_line_path.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// If the path size is equal to 1, then DebugDraw3D.draw_square will be used instead of drawing a line.
    /// </para>
    ///
    /// </summary>
    /// <param name="path">Sequence of points</param>
    /// <param name="color">Primary color</param>
    /// <param name="arrow_size">Size of the arrow</param>
    /// <param name="is_absolute_size">Is the `arrow_size` absolute or relative to the length of the line?</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawArrowPath(Vector3[] path, Color? color = null, real_t arrow_size = 0.75f, bool is_absolute_size = true, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_arrow_path_c", ref func_DebugDraw3D_draw_arrow_path_c, ref func_load_result_DebugDraw3D_draw_arrow_path_c))
                return;

            var path_native_fixed = GCHandle.Alloc(path, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_arrow_path_c(path_native_fixed.AddrOfPinnedObject(), (ulong)path.Length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, arrow_size, is_absolute_size, duration);
            }
            finally
            {
                path_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw a sequence of points connected by lines using billboard squares or spheres like DebugDraw3D.draw_line_path.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// <para>
    /// If the path size is equal to 1, then DebugDraw3D.draw_square or DebugDraw3D.draw_sphere will be used instead of drawing a line.
    /// </para>
    ///
    /// </summary>
    /// <param name="path">Sequence of points</param>
    /// <param name="type">Type of points</param>
    /// <param name="points_color">Color of points</param>
    /// <param name="lines_color">Color of lines</param>
    /// <param name="size">Size of squares</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawPointPath(Vector3[] path, DebugDraw3D.PointType type = PointType.TypeSquare, real_t size = 0.25f, Color? points_color = null, Color? lines_color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_point_path_c", ref func_DebugDraw3D_draw_point_path_c, ref func_load_result_DebugDraw3D_draw_point_path_c))
                return;

            var path_native_fixed = GCHandle.Alloc(path, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_point_path_c(path_native_fixed.AddrOfPinnedObject(), (ulong)path.Length, (uint)(type), size, points_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, lines_color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
            }
            finally
            {
                path_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw a sequence of points using billboard squares or spheres.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="points">Sequence of points</param>
    /// <param name="type">Type of points</param>
    /// <param name="size">Size of squares</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawPoints(Vector3[] points, DebugDraw3D.PointType type = DebugDraw3D.PointType.TypeSquare, real_t size = 0.25f, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_points_c", ref func_DebugDraw3D_draw_points_c, ref func_load_result_DebugDraw3D_draw_points_c))
                return;

            var points_native_fixed = GCHandle.Alloc(points, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_points_c(points_native_fixed.AddrOfPinnedObject(), (ulong)points.Length, (uint)(type), size, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
            }
            finally
            {
                points_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw a square that will always be turned towards the camera
    ///
    /// </summary>
    /// <param name="position">Center position of square</param>
    /// <param name="size">Square size</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawSquare(Vector3 position, real_t size = 0.2f, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_square", ref func_DebugDraw3D_draw_square, ref func_load_result_DebugDraw3D_draw_square))
                return;
            func_DebugDraw3D_draw_square(position, size, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draws a plane of non-infinite size relative to the position of the current camera.
    ///
    /// The plane size is set based on the `Far` parameter of the current camera or with DebugDraw3DScopeConfig.set_plane_size.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="plane">Plane data</param>
    /// <param name="color">Primary color</param>
    /// <param name="anchor_point">A point that is projected onto a Plane, and its projection is used as the center of the drawn plane</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawPlane(Plane plane, Color? color = null, Vector3? anchor_point = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_plane", ref func_DebugDraw3D_draw_plane, ref func_load_result_DebugDraw3D_draw_plane))
                return;
            func_DebugDraw3D_draw_plane(plane, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, anchor_point ?? InternalDD3DApiLoaderUtils_._default_arg_2, duration);
#endif
        }
    }

    /// <summary>
    /// Draw 3 intersecting lines with the given transformations
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="transform">godot::Transform3D of lines</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawPosition(Transform3D transform, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_position", ref func_DebugDraw3D_draw_position, ref func_load_result_DebugDraw3D_draw_position))
                return;
            func_DebugDraw3D_draw_position(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw 3 lines with the given transformations and arrows at the ends
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="transform">godot::Transform3D of lines</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_centered">If `true`, then the lines will intersect in the center of the transform</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawGizmo(Transform3D transform, Color? color = null, bool is_centered = false, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_gizmo", ref func_DebugDraw3D_draw_gizmo, ref func_load_result_DebugDraw3D_draw_gizmo))
                return;
            func_DebugDraw3D_draw_gizmo(transform, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_centered, duration);
#endif
        }
    }

    /// <summary>
    /// Draw simple grid with given size and subdivision
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="origin">Grid origin</param>
    /// <param name="x_size">Direction and size of the X side. As an axis in the Basis.</param>
    /// <param name="y_size">Direction and size of the Y side. As an axis in the Basis.</param>
    /// <param name="subdivision">Number of cells for the X and Y axes</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_centered">Draw lines relative to origin</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawGrid(Vector3 origin, Vector3 x_size, Vector3 y_size, Vector2I subdivision, Color? color = null, bool is_centered = true, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_grid", ref func_DebugDraw3D_draw_grid, ref func_load_result_DebugDraw3D_draw_grid))
                return;
            func_DebugDraw3D_draw_grid(origin, x_size, y_size, subdivision, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_centered, duration);
#endif
        }
    }

    /// <summary>
    /// Draw a simple grid with a given transform and subdivision.
    ///
    /// Like DebugDraw3D.draw_grid, but instead of origin, x_size and y_size, a single transform is used.
    ///
    /// </summary>
    /// <param name="transform">godot::Transform3D of the Grid</param>
    /// <param name="p_subdivision">Number of cells for the X and Y axes</param>
    /// <param name="color">Primary color</param>
    /// <param name="is_centered">Draw lines relative to origin</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawGridXf(Transform3D transform, Vector2I p_subdivision, Color? color = null, bool is_centered = true, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_grid_xf", ref func_DebugDraw3D_draw_grid_xf, ref func_load_result_DebugDraw3D_draw_grid_xf))
                return;
            func_DebugDraw3D_draw_grid_xf(transform, p_subdivision, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, is_centered, duration);
#endif
        }
    }

    /// <summary>
    /// Draw camera frustum area.
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="camera">Camera node</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCameraFrustum(Camera3D camera, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_camera_frustum", ref func_DebugDraw3D_draw_camera_frustum, ref func_load_result_DebugDraw3D_draw_camera_frustum))
                return;
            func_DebugDraw3D_draw_camera_frustum(camera != null ? camera.GetInstanceId() : 0, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

    /// <summary>
    /// Draw the frustum area of the camera based on an array of 6 planes.
    ///
    /// </summary>
    /// <param name="camera_frustum">Array of frustum planes</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawCameraFrustumPlanes(Plane[] camera_frustum, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_camera_frustum_planes_c", ref func_DebugDraw3D_draw_camera_frustum_planes_c, ref func_load_result_DebugDraw3D_draw_camera_frustum_planes_c))
                return;

            var camera_frustum_native_fixed = GCHandle.Alloc(camera_frustum, GCHandleType.Pinned);
            try
            {
                func_DebugDraw3D_draw_camera_frustum_planes_c(camera_frustum_native_fixed.AddrOfPinnedObject(), (ulong)camera_frustum.Length, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
            }
            finally
            {
                camera_frustum_native_fixed.Free();
            }
#endif
        }
    }

    /// <summary>
    /// Draw text using Label3D.
    ///
    /// <para>
    /// Outline can be changed using DebugDraw3DScopeConfig.set_text_outline_color and DebugDraw3DScopeConfig.set_text_outline_size.
    /// The font can be changed using DebugDraw3DScopeConfig.set_text_font.
    /// The text can be made to stay the same size regardless of distance using DebugDraw3DScopeConfig.set_text_fixed_size.
    /// </para>
    ///
    /// [THERE WAS AN IMAGE]
    ///
    /// </summary>
    /// <param name="position">Center position of Label</param>
    /// <param name="text">Label's text</param>
    /// <param name="size">Font size</param>
    /// <param name="color">Primary color</param>
    /// <param name="duration">The duration of how long the object will be visible</param>
    public static void DrawText(Vector3 position, string text, int size = 32, Color? color = null, real_t duration = 0)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3D_draw_text_c", ref func_DebugDraw3D_draw_text_c, ref func_load_result_DebugDraw3D_draw_text_c))
                return;
            func_DebugDraw3D_draw_text_c(position, text, size, color ?? InternalDD3DApiLoaderUtils_._default_arg_1, duration);
#endif
        }
    }

} // class DebugDraw3D

/// <summary>
/// <para>
/// You can get statistics about 3D rendering from this class.
/// </para>
///
/// All names try to reflect what they mean.
///
/// To get an instance of this class with current statistics, use DebugDraw3D.get_render_stats.
///
/// `instances` lets you know how many instances have been created.
///
/// `instances_physics` reports how many instances were created inside `_physics_process`.
///
/// `total_time_spent_usec` reports the time in microseconds spent to process everything and display the geometry on the screen.
/// </summary>
internal class DebugDraw3DStats : IDisposable
{
    IntPtr inst_ptr;

    public DebugDraw3DStats(IntPtr inst_ptr)
    {
        this.inst_ptr = inst_ptr;
    }

    public DebugDraw3DStats(bool instantiate = true)
    {
        this.inst_ptr = instantiate ? Create() : CreateNullptr();
    }

    ~DebugDraw3DStats() => Dispose();

    public static explicit operator IntPtr(DebugDraw3DStats o) { return o.inst_ptr; }

    public void Dispose()
    {
        if (inst_ptr != IntPtr.Zero)
        {
            Destroy(inst_ptr);
            inst_ptr = IntPtr.Zero;
        }
    }

    public long Instances { get => GetInstances(); set => SetInstances(value); }

    public long Lines { get => GetLines(); set => SetLines(value); }

    public long InstancesPhysics { get => GetInstancesPhysics(); set => SetInstancesPhysics(value); }

    public long LinesPhysics { get => GetLinesPhysics(); set => SetLinesPhysics(value); }

    public long TotalGeometry { get => GetTotalGeometry(); set => SetTotalGeometry(value); }

    public long VisibleInstances { get => GetVisibleInstances(); set => SetVisibleInstances(value); }

    public long VisibleLines { get => GetVisibleLines(); set => SetVisibleLines(value); }

    public long TotalVisible { get => GetTotalVisible(); set => SetTotalVisible(value); }

    public long TimeFillingBuffersInstancesUsec { get => GetTimeFillingBuffersInstancesUsec(); set => SetTimeFillingBuffersInstancesUsec(value); }

    public long TimeFillingBuffersLinesUsec { get => GetTimeFillingBuffersLinesUsec(); set => SetTimeFillingBuffersLinesUsec(value); }

    public long TimeFillingBuffersInstancesPhysicsUsec { get => GetTimeFillingBuffersInstancesPhysicsUsec(); set => SetTimeFillingBuffersInstancesPhysicsUsec(value); }

    public long TimeFillingBuffersLinesPhysicsUsec { get => GetTimeFillingBuffersLinesPhysicsUsec(); set => SetTimeFillingBuffersLinesPhysicsUsec(value); }

    public long TotalTimeFillingBuffersUsec { get => GetTotalTimeFillingBuffersUsec(); set => SetTotalTimeFillingBuffersUsec(value); }

    public long TimeCullingInstancesUsec { get => GetTimeCullingInstancesUsec(); set => SetTimeCullingInstancesUsec(value); }

    public long TimeCullingLinesUsec { get => GetTimeCullingLinesUsec(); set => SetTimeCullingLinesUsec(value); }

    public long TotalTimeCullingUsec { get => GetTotalTimeCullingUsec(); set => SetTotalTimeCullingUsec(value); }

    public long TotalTimeSpentUsec { get => GetTotalTimeSpentUsec(); set => SetTotalTimeSpentUsec(value); }

    public long CreatedScopedConfigs { get => GetCreatedScopedConfigs(); set => SetCreatedScopedConfigs(value); }

    public long OrphanScopedConfigs { get => GetOrphanScopedConfigs(); set => SetOrphanScopedConfigs(value); }

    public long NodesLabel3dVisible { get => GetNodesLabel3dVisible(); set => SetNodesLabel3dVisible(value); }

    public long NodesLabel3dVisiblePhysics { get => GetNodesLabel3dVisiblePhysics(); set => SetNodesLabel3dVisiblePhysics(value); }

    public long NodesLabel3dExists { get => GetNodesLabel3dExists(); set => SetNodesLabel3dExists(value); }

    public long NodesLabel3dExistsPhysics { get => GetNodesLabel3dExistsPhysics(); set => SetNodesLabel3dExistsPhysics(value); }

    public long NodesLabel3dExistsTotal { get => GetNodesLabel3dExistsTotal(); set => SetNodesLabel3dExistsTotal(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_instances(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_instances func_DebugDraw3DStats_get_instances; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_instances;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_instances(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_instances func_DebugDraw3DStats_set_instances; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_instances;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_lines(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_lines func_DebugDraw3DStats_get_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_lines(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_lines func_DebugDraw3DStats_set_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_instances_physics(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_instances_physics func_DebugDraw3DStats_get_instances_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_instances_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_instances_physics(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_instances_physics func_DebugDraw3DStats_set_instances_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_instances_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_lines_physics(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_lines_physics func_DebugDraw3DStats_get_lines_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_lines_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_lines_physics(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_lines_physics func_DebugDraw3DStats_set_lines_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_lines_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_total_geometry(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_total_geometry func_DebugDraw3DStats_get_total_geometry; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_total_geometry;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_total_geometry(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_total_geometry func_DebugDraw3DStats_set_total_geometry; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_total_geometry;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_visible_instances(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_visible_instances func_DebugDraw3DStats_get_visible_instances; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_visible_instances;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_visible_instances(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_visible_instances func_DebugDraw3DStats_set_visible_instances; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_visible_instances;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_visible_lines(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_visible_lines func_DebugDraw3DStats_get_visible_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_visible_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_visible_lines(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_visible_lines func_DebugDraw3DStats_set_visible_lines; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_visible_lines;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_total_visible(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_total_visible func_DebugDraw3DStats_get_total_visible; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_total_visible;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_total_visible(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_total_visible func_DebugDraw3DStats_set_total_visible; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_total_visible;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_filling_buffers_instances_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_filling_buffers_instances_usec func_DebugDraw3DStats_get_time_filling_buffers_instances_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_filling_buffers_instances_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_filling_buffers_instances_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_filling_buffers_instances_usec func_DebugDraw3DStats_set_time_filling_buffers_instances_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_filling_buffers_instances_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_filling_buffers_lines_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_filling_buffers_lines_usec func_DebugDraw3DStats_get_time_filling_buffers_lines_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_filling_buffers_lines_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_filling_buffers_lines_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_filling_buffers_lines_usec func_DebugDraw3DStats_set_time_filling_buffers_lines_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_filling_buffers_lines_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec func_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec func_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec func_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec func_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_total_time_filling_buffers_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_total_time_filling_buffers_usec func_DebugDraw3DStats_get_total_time_filling_buffers_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_total_time_filling_buffers_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_total_time_filling_buffers_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_total_time_filling_buffers_usec func_DebugDraw3DStats_set_total_time_filling_buffers_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_total_time_filling_buffers_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_culling_instances_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_culling_instances_usec func_DebugDraw3DStats_get_time_culling_instances_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_culling_instances_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_culling_instances_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_culling_instances_usec func_DebugDraw3DStats_set_time_culling_instances_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_culling_instances_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_time_culling_lines_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_time_culling_lines_usec func_DebugDraw3DStats_get_time_culling_lines_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_time_culling_lines_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_time_culling_lines_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_time_culling_lines_usec func_DebugDraw3DStats_set_time_culling_lines_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_time_culling_lines_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_total_time_culling_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_total_time_culling_usec func_DebugDraw3DStats_get_total_time_culling_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_total_time_culling_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_total_time_culling_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_total_time_culling_usec func_DebugDraw3DStats_set_total_time_culling_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_total_time_culling_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_total_time_spent_usec(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_total_time_spent_usec func_DebugDraw3DStats_get_total_time_spent_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_total_time_spent_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_total_time_spent_usec(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_total_time_spent_usec func_DebugDraw3DStats_set_total_time_spent_usec; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_total_time_spent_usec;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_created_scoped_configs(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_created_scoped_configs func_DebugDraw3DStats_get_created_scoped_configs; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_created_scoped_configs;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_created_scoped_configs(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_created_scoped_configs func_DebugDraw3DStats_set_created_scoped_configs; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_created_scoped_configs;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_orphan_scoped_configs(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_orphan_scoped_configs func_DebugDraw3DStats_get_orphan_scoped_configs; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_orphan_scoped_configs;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_orphan_scoped_configs(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_orphan_scoped_configs func_DebugDraw3DStats_set_orphan_scoped_configs; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_orphan_scoped_configs;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_nodes_label3d_visible(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_nodes_label3d_visible func_DebugDraw3DStats_get_nodes_label3d_visible; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_nodes_label3d_visible;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_nodes_label3d_visible(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_nodes_label3d_visible func_DebugDraw3DStats_set_nodes_label3d_visible; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_nodes_label3d_visible;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_nodes_label3d_visible_physics(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_nodes_label3d_visible_physics func_DebugDraw3DStats_get_nodes_label3d_visible_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_nodes_label3d_visible_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_nodes_label3d_visible_physics(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_nodes_label3d_visible_physics func_DebugDraw3DStats_set_nodes_label3d_visible_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_nodes_label3d_visible_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_nodes_label3d_exists(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_nodes_label3d_exists func_DebugDraw3DStats_get_nodes_label3d_exists; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_nodes_label3d_exists;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_nodes_label3d_exists(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_nodes_label3d_exists func_DebugDraw3DStats_set_nodes_label3d_exists; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_nodes_label3d_exists;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_nodes_label3d_exists_physics(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_nodes_label3d_exists_physics func_DebugDraw3DStats_get_nodes_label3d_exists_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_nodes_label3d_exists_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_nodes_label3d_exists_physics(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_nodes_label3d_exists_physics func_DebugDraw3DStats_set_nodes_label3d_exists_physics; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_nodes_label3d_exists_physics;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate long dlgt_DebugDraw3DStats_get_nodes_label3d_exists_total(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_get_nodes_label3d_exists_total func_DebugDraw3DStats_get_nodes_label3d_exists_total; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_get_nodes_label3d_exists_total;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_set_nodes_label3d_exists_total(IntPtr inst_ptr, long val);
    static dlgt_DebugDraw3DStats_set_nodes_label3d_exists_total func_DebugDraw3DStats_set_nodes_label3d_exists_total; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_set_nodes_label3d_exists_total;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DStats_create();
    static dlgt_DebugDraw3DStats_create func_DebugDraw3DStats_create; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_create;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate IntPtr dlgt_DebugDraw3DStats_create_nullptr();
    static dlgt_DebugDraw3DStats_create_nullptr func_DebugDraw3DStats_create_nullptr; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_create_nullptr;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDraw3DStats_destroy(IntPtr inst_ptr);
    static dlgt_DebugDraw3DStats_destroy func_DebugDraw3DStats_destroy; static DD3DFuncLoadingResult func_load_result_DebugDraw3DStats_destroy;

    public long GetInstances()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_instances", ref func_DebugDraw3DStats_get_instances, ref func_load_result_DebugDraw3DStats_get_instances))
            return default;
        return func_DebugDraw3DStats_get_instances(inst_ptr);
    }

    public void SetInstances(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_instances", ref func_DebugDraw3DStats_set_instances, ref func_load_result_DebugDraw3DStats_set_instances))
                return;
            func_DebugDraw3DStats_set_instances(inst_ptr, val);
#endif
        }
    }

    public long GetLines()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_lines", ref func_DebugDraw3DStats_get_lines, ref func_load_result_DebugDraw3DStats_get_lines))
            return default;
        return func_DebugDraw3DStats_get_lines(inst_ptr);
    }

    public void SetLines(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_lines", ref func_DebugDraw3DStats_set_lines, ref func_load_result_DebugDraw3DStats_set_lines))
                return;
            func_DebugDraw3DStats_set_lines(inst_ptr, val);
#endif
        }
    }

    public long GetInstancesPhysics()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_instances_physics", ref func_DebugDraw3DStats_get_instances_physics, ref func_load_result_DebugDraw3DStats_get_instances_physics))
            return default;
        return func_DebugDraw3DStats_get_instances_physics(inst_ptr);
    }

    public void SetInstancesPhysics(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_instances_physics", ref func_DebugDraw3DStats_set_instances_physics, ref func_load_result_DebugDraw3DStats_set_instances_physics))
                return;
            func_DebugDraw3DStats_set_instances_physics(inst_ptr, val);
#endif
        }
    }

    public long GetLinesPhysics()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_lines_physics", ref func_DebugDraw3DStats_get_lines_physics, ref func_load_result_DebugDraw3DStats_get_lines_physics))
            return default;
        return func_DebugDraw3DStats_get_lines_physics(inst_ptr);
    }

    public void SetLinesPhysics(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_lines_physics", ref func_DebugDraw3DStats_set_lines_physics, ref func_load_result_DebugDraw3DStats_set_lines_physics))
                return;
            func_DebugDraw3DStats_set_lines_physics(inst_ptr, val);
#endif
        }
    }

    public long GetTotalGeometry()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_total_geometry", ref func_DebugDraw3DStats_get_total_geometry, ref func_load_result_DebugDraw3DStats_get_total_geometry))
            return default;
        return func_DebugDraw3DStats_get_total_geometry(inst_ptr);
    }

    public void SetTotalGeometry(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_total_geometry", ref func_DebugDraw3DStats_set_total_geometry, ref func_load_result_DebugDraw3DStats_set_total_geometry))
                return;
            func_DebugDraw3DStats_set_total_geometry(inst_ptr, val);
#endif
        }
    }

    public long GetVisibleInstances()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_visible_instances", ref func_DebugDraw3DStats_get_visible_instances, ref func_load_result_DebugDraw3DStats_get_visible_instances))
            return default;
        return func_DebugDraw3DStats_get_visible_instances(inst_ptr);
    }

    public void SetVisibleInstances(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_visible_instances", ref func_DebugDraw3DStats_set_visible_instances, ref func_load_result_DebugDraw3DStats_set_visible_instances))
                return;
            func_DebugDraw3DStats_set_visible_instances(inst_ptr, val);
#endif
        }
    }

    public long GetVisibleLines()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_visible_lines", ref func_DebugDraw3DStats_get_visible_lines, ref func_load_result_DebugDraw3DStats_get_visible_lines))
            return default;
        return func_DebugDraw3DStats_get_visible_lines(inst_ptr);
    }

    public void SetVisibleLines(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_visible_lines", ref func_DebugDraw3DStats_set_visible_lines, ref func_load_result_DebugDraw3DStats_set_visible_lines))
                return;
            func_DebugDraw3DStats_set_visible_lines(inst_ptr, val);
#endif
        }
    }

    public long GetTotalVisible()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_total_visible", ref func_DebugDraw3DStats_get_total_visible, ref func_load_result_DebugDraw3DStats_get_total_visible))
            return default;
        return func_DebugDraw3DStats_get_total_visible(inst_ptr);
    }

    public void SetTotalVisible(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_total_visible", ref func_DebugDraw3DStats_set_total_visible, ref func_load_result_DebugDraw3DStats_set_total_visible))
                return;
            func_DebugDraw3DStats_set_total_visible(inst_ptr, val);
#endif
        }
    }

    public long GetTimeFillingBuffersInstancesUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_filling_buffers_instances_usec", ref func_DebugDraw3DStats_get_time_filling_buffers_instances_usec, ref func_load_result_DebugDraw3DStats_get_time_filling_buffers_instances_usec))
            return default;
        return func_DebugDraw3DStats_get_time_filling_buffers_instances_usec(inst_ptr);
    }

    public void SetTimeFillingBuffersInstancesUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_filling_buffers_instances_usec", ref func_DebugDraw3DStats_set_time_filling_buffers_instances_usec, ref func_load_result_DebugDraw3DStats_set_time_filling_buffers_instances_usec))
                return;
            func_DebugDraw3DStats_set_time_filling_buffers_instances_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTimeFillingBuffersLinesUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_filling_buffers_lines_usec", ref func_DebugDraw3DStats_get_time_filling_buffers_lines_usec, ref func_load_result_DebugDraw3DStats_get_time_filling_buffers_lines_usec))
            return default;
        return func_DebugDraw3DStats_get_time_filling_buffers_lines_usec(inst_ptr);
    }

    public void SetTimeFillingBuffersLinesUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_filling_buffers_lines_usec", ref func_DebugDraw3DStats_set_time_filling_buffers_lines_usec, ref func_load_result_DebugDraw3DStats_set_time_filling_buffers_lines_usec))
                return;
            func_DebugDraw3DStats_set_time_filling_buffers_lines_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTimeFillingBuffersInstancesPhysicsUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec", ref func_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec, ref func_load_result_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec))
            return default;
        return func_DebugDraw3DStats_get_time_filling_buffers_instances_physics_usec(inst_ptr);
    }

    public void SetTimeFillingBuffersInstancesPhysicsUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec", ref func_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec, ref func_load_result_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec))
                return;
            func_DebugDraw3DStats_set_time_filling_buffers_instances_physics_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTimeFillingBuffersLinesPhysicsUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec", ref func_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec, ref func_load_result_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec))
            return default;
        return func_DebugDraw3DStats_get_time_filling_buffers_lines_physics_usec(inst_ptr);
    }

    public void SetTimeFillingBuffersLinesPhysicsUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec", ref func_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec, ref func_load_result_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec))
                return;
            func_DebugDraw3DStats_set_time_filling_buffers_lines_physics_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTotalTimeFillingBuffersUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_total_time_filling_buffers_usec", ref func_DebugDraw3DStats_get_total_time_filling_buffers_usec, ref func_load_result_DebugDraw3DStats_get_total_time_filling_buffers_usec))
            return default;
        return func_DebugDraw3DStats_get_total_time_filling_buffers_usec(inst_ptr);
    }

    public void SetTotalTimeFillingBuffersUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_total_time_filling_buffers_usec", ref func_DebugDraw3DStats_set_total_time_filling_buffers_usec, ref func_load_result_DebugDraw3DStats_set_total_time_filling_buffers_usec))
                return;
            func_DebugDraw3DStats_set_total_time_filling_buffers_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTimeCullingInstancesUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_culling_instances_usec", ref func_DebugDraw3DStats_get_time_culling_instances_usec, ref func_load_result_DebugDraw3DStats_get_time_culling_instances_usec))
            return default;
        return func_DebugDraw3DStats_get_time_culling_instances_usec(inst_ptr);
    }

    public void SetTimeCullingInstancesUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_culling_instances_usec", ref func_DebugDraw3DStats_set_time_culling_instances_usec, ref func_load_result_DebugDraw3DStats_set_time_culling_instances_usec))
                return;
            func_DebugDraw3DStats_set_time_culling_instances_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTimeCullingLinesUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_time_culling_lines_usec", ref func_DebugDraw3DStats_get_time_culling_lines_usec, ref func_load_result_DebugDraw3DStats_get_time_culling_lines_usec))
            return default;
        return func_DebugDraw3DStats_get_time_culling_lines_usec(inst_ptr);
    }

    public void SetTimeCullingLinesUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_time_culling_lines_usec", ref func_DebugDraw3DStats_set_time_culling_lines_usec, ref func_load_result_DebugDraw3DStats_set_time_culling_lines_usec))
                return;
            func_DebugDraw3DStats_set_time_culling_lines_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTotalTimeCullingUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_total_time_culling_usec", ref func_DebugDraw3DStats_get_total_time_culling_usec, ref func_load_result_DebugDraw3DStats_get_total_time_culling_usec))
            return default;
        return func_DebugDraw3DStats_get_total_time_culling_usec(inst_ptr);
    }

    public void SetTotalTimeCullingUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_total_time_culling_usec", ref func_DebugDraw3DStats_set_total_time_culling_usec, ref func_load_result_DebugDraw3DStats_set_total_time_culling_usec))
                return;
            func_DebugDraw3DStats_set_total_time_culling_usec(inst_ptr, val);
#endif
        }
    }

    public long GetTotalTimeSpentUsec()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_total_time_spent_usec", ref func_DebugDraw3DStats_get_total_time_spent_usec, ref func_load_result_DebugDraw3DStats_get_total_time_spent_usec))
            return default;
        return func_DebugDraw3DStats_get_total_time_spent_usec(inst_ptr);
    }

    public void SetTotalTimeSpentUsec(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_total_time_spent_usec", ref func_DebugDraw3DStats_set_total_time_spent_usec, ref func_load_result_DebugDraw3DStats_set_total_time_spent_usec))
                return;
            func_DebugDraw3DStats_set_total_time_spent_usec(inst_ptr, val);
#endif
        }
    }

    public long GetCreatedScopedConfigs()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_created_scoped_configs", ref func_DebugDraw3DStats_get_created_scoped_configs, ref func_load_result_DebugDraw3DStats_get_created_scoped_configs))
            return default;
        return func_DebugDraw3DStats_get_created_scoped_configs(inst_ptr);
    }

    public void SetCreatedScopedConfigs(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_created_scoped_configs", ref func_DebugDraw3DStats_set_created_scoped_configs, ref func_load_result_DebugDraw3DStats_set_created_scoped_configs))
                return;
            func_DebugDraw3DStats_set_created_scoped_configs(inst_ptr, val);
#endif
        }
    }

    public long GetOrphanScopedConfigs()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_orphan_scoped_configs", ref func_DebugDraw3DStats_get_orphan_scoped_configs, ref func_load_result_DebugDraw3DStats_get_orphan_scoped_configs))
            return default;
        return func_DebugDraw3DStats_get_orphan_scoped_configs(inst_ptr);
    }

    public void SetOrphanScopedConfigs(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_orphan_scoped_configs", ref func_DebugDraw3DStats_set_orphan_scoped_configs, ref func_load_result_DebugDraw3DStats_set_orphan_scoped_configs))
                return;
            func_DebugDraw3DStats_set_orphan_scoped_configs(inst_ptr, val);
#endif
        }
    }

    public long GetNodesLabel3dVisible()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_nodes_label3d_visible", ref func_DebugDraw3DStats_get_nodes_label3d_visible, ref func_load_result_DebugDraw3DStats_get_nodes_label3d_visible))
            return default;
        return func_DebugDraw3DStats_get_nodes_label3d_visible(inst_ptr);
    }

    public void SetNodesLabel3dVisible(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_nodes_label3d_visible", ref func_DebugDraw3DStats_set_nodes_label3d_visible, ref func_load_result_DebugDraw3DStats_set_nodes_label3d_visible))
                return;
            func_DebugDraw3DStats_set_nodes_label3d_visible(inst_ptr, val);
#endif
        }
    }

    public long GetNodesLabel3dVisiblePhysics()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_nodes_label3d_visible_physics", ref func_DebugDraw3DStats_get_nodes_label3d_visible_physics, ref func_load_result_DebugDraw3DStats_get_nodes_label3d_visible_physics))
            return default;
        return func_DebugDraw3DStats_get_nodes_label3d_visible_physics(inst_ptr);
    }

    public void SetNodesLabel3dVisiblePhysics(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_nodes_label3d_visible_physics", ref func_DebugDraw3DStats_set_nodes_label3d_visible_physics, ref func_load_result_DebugDraw3DStats_set_nodes_label3d_visible_physics))
                return;
            func_DebugDraw3DStats_set_nodes_label3d_visible_physics(inst_ptr, val);
#endif
        }
    }

    public long GetNodesLabel3dExists()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_nodes_label3d_exists", ref func_DebugDraw3DStats_get_nodes_label3d_exists, ref func_load_result_DebugDraw3DStats_get_nodes_label3d_exists))
            return default;
        return func_DebugDraw3DStats_get_nodes_label3d_exists(inst_ptr);
    }

    public void SetNodesLabel3dExists(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_nodes_label3d_exists", ref func_DebugDraw3DStats_set_nodes_label3d_exists, ref func_load_result_DebugDraw3DStats_set_nodes_label3d_exists))
                return;
            func_DebugDraw3DStats_set_nodes_label3d_exists(inst_ptr, val);
#endif
        }
    }

    public long GetNodesLabel3dExistsPhysics()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_nodes_label3d_exists_physics", ref func_DebugDraw3DStats_get_nodes_label3d_exists_physics, ref func_load_result_DebugDraw3DStats_get_nodes_label3d_exists_physics))
            return default;
        return func_DebugDraw3DStats_get_nodes_label3d_exists_physics(inst_ptr);
    }

    public void SetNodesLabel3dExistsPhysics(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_nodes_label3d_exists_physics", ref func_DebugDraw3DStats_set_nodes_label3d_exists_physics, ref func_load_result_DebugDraw3DStats_set_nodes_label3d_exists_physics))
                return;
            func_DebugDraw3DStats_set_nodes_label3d_exists_physics(inst_ptr, val);
#endif
        }
    }

    public long GetNodesLabel3dExistsTotal()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_get_nodes_label3d_exists_total", ref func_DebugDraw3DStats_get_nodes_label3d_exists_total, ref func_load_result_DebugDraw3DStats_get_nodes_label3d_exists_total))
            return default;
        return func_DebugDraw3DStats_get_nodes_label3d_exists_total(inst_ptr);
    }

    public void SetNodesLabel3dExistsTotal(long val)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_set_nodes_label3d_exists_total", ref func_DebugDraw3DStats_set_nodes_label3d_exists_total, ref func_load_result_DebugDraw3DStats_set_nodes_label3d_exists_total))
                return;
            func_DebugDraw3DStats_set_nodes_label3d_exists_total(inst_ptr, val);
#endif
        }
    }

    private static IntPtr Create()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_create", ref func_DebugDraw3DStats_create, ref func_load_result_DebugDraw3DStats_create))
            return IntPtr.Zero;
        return func_DebugDraw3DStats_create();
    }

    private static IntPtr CreateNullptr()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_create_nullptr", ref func_DebugDraw3DStats_create_nullptr, ref func_load_result_DebugDraw3DStats_create_nullptr))
            return IntPtr.Zero;
        return func_DebugDraw3DStats_create_nullptr();
    }

    private static void Destroy(IntPtr inst_ptr)
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDraw3DStats_destroy", ref func_DebugDraw3DStats_destroy, ref func_load_result_DebugDraw3DStats_destroy))
            return;
        func_DebugDraw3DStats_destroy(inst_ptr);
    }

}; // class DebugDraw3DStats

/// <summary>
/// <para>
/// The main singleton class that handles DebugDraw2D and DebugDraw3D.
/// </para>
///
/// Several additional settings can be found in the project settings.
///
/// <para> The following settings require a restart.
/// </para>
///
/// `debug_draw_3d/settings/initial_debug_state` sets the initial debugging state.
///
/// `debug_draw_3d/settings/common/DebugDrawManager_singleton_aliases` sets aliases for DebugDrawManager to be registered as additional singletons.
///
/// `debug_draw_3d/settings/common/DebugDraw2D_singleton_aliases` sets aliases for DebugDraw2D to be registered as additional singletons.
///
/// `debug_draw_3d/settings/common/DebugDraw3D_singleton_aliases` sets aliases for DebugDraw3D to be registered as additional singletons.
///
/// Using these aliases you can reference singletons with shorter words:
///
/// <code>
/// var _s = Dbg3.new_scoped_config().set_thickness(0.025).set_center_brightness(0.7)
/// Dbg3.draw_grid_xf(%Grid.global_transform, Vector2i(10,10), Color.LIGHT_GRAY)
/// Dbg2.set_text("Frametime", delta)
/// </code>
/// </summary>
internal static class DebugDrawManager
{
    /// <summary>
    /// Set whether to display 2D and 3D debug graphics
    /// </summary>
    public static bool DebugEnabled { get => IsDebugEnabled(); set => SetDebugEnabled(value); }


    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDrawManager_clear_all();
    static dlgt_DebugDrawManager_clear_all func_DebugDrawManager_clear_all; static DD3DFuncLoadingResult func_load_result_DebugDrawManager_clear_all;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void dlgt_DebugDrawManager_set_debug_enabled(bool value);
    static dlgt_DebugDrawManager_set_debug_enabled func_DebugDrawManager_set_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDrawManager_set_debug_enabled;
    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate bool dlgt_DebugDrawManager_is_debug_enabled();
    static dlgt_DebugDrawManager_is_debug_enabled func_DebugDrawManager_is_debug_enabled; static DD3DFuncLoadingResult func_load_result_DebugDrawManager_is_debug_enabled;

    /// <summary>
    /// Clear all 2D and 3D geometry
    /// </summary>
    public static void ClearAll()
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDrawManager_clear_all", ref func_DebugDrawManager_clear_all, ref func_load_result_DebugDrawManager_clear_all))
                return;
            func_DebugDrawManager_clear_all();
#endif
        }
    }

    /// <summary>
    /// Set whether to display 2D and 3D debug graphics
    /// </summary>
    public static void SetDebugEnabled(bool value)
    {
#if _DD3D_RUNTIME_CHECK_ENABLED
        if (InternalDD3DApiLoaderUtils_.IsCallEnabled)
#endif
        {
#if _DD3D_COMPILETIME_CHECK_ENABLED
            if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDrawManager_set_debug_enabled", ref func_DebugDrawManager_set_debug_enabled, ref func_load_result_DebugDrawManager_set_debug_enabled))
                return;
            func_DebugDrawManager_set_debug_enabled(value);
#endif
        }
    }

    /// <summary>
    /// Whether debug 2D and 3D graphics are disabled
    /// </summary>
    public static bool IsDebugEnabled()
    {
        if (!InternalDD3DApiLoaderUtils_.LoadFunction("DebugDrawManager_is_debug_enabled", ref func_DebugDrawManager_is_debug_enabled, ref func_load_result_DebugDrawManager_is_debug_enabled))
            return default;
        return func_DebugDrawManager_is_debug_enabled();
    }

} // class DebugDrawManager

// End of the generated API
