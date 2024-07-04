const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const qtbase_dep = b.dependency("qtbase", .{});

    const syncqt_exe = b.addExecutable(.{
        .name = "syncqt",
        .target = b.host,
    });
    syncqt_exe.addCSourceFiles(.{
        .root = qtbase_dep.path("."),
        .files = &.{ "src/tools/syncqt/main.cpp" },
        .flags = &.{
            "-std=c++17",
            //QT_VERSION_STR="${PROJECT_VERSION}"
            //QT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
            //QT_VERSION_MINOR=${PROJECT_VERSION_MINOR}
            //QT_VERSION_PATCH=${PROJECT_VERSION_PATCH}
        },
    });
    syncqt_exe.defineCMacro("QT_VERSION_STR", "\"6.7.2\"");
    syncqt_exe.defineCMacro("QT_VERSION_MAJOR", "6");
    syncqt_exe.defineCMacro("QT_VERSION_MINOR", "7");
    syncqt_exe.defineCMacro("QT_VERSION_PATCH", "2");
    syncqt_exe.linkLibCpp();
    //b.installArtifact(syncqt_exe);

    const core_inc = module_core.makeSyncQt(b, qtbase_dep, syncqt_exe);
    const gui_inc = module_gui.makeSyncQt(b, qtbase_dep, syncqt_exe);
    const widgets_inc = module_widgets.makeSyncQt(b, qtbase_dep, syncqt_exe);

    const write_files = b.addWriteFiles();
    _ = write_files.add("QtCore/qconfig.h",
        \\//#define QT_BOOTSTRAPPED
        \\#define QT_VERSION_MAJOR 6
        \\#define QT_VERSION_MINOR 7
        \\#define QT_VERSION_PATCH 2
        \\//#define QT_DEPRECATED_SINCE(maj,min) 0
        \\#define QT_MODULE_CORE
        \\#define QT_MODULE_GUI
        \\#define QT_MODULE_WIDGETS
        \\#define QT_CORE_REMOVED_SINCE(...) 0
        \\#define QT_CORE_INLINE_SINCE(...)
        \\#define QT_CORE_INLINE_IMPL_SINCE(...) 0
        \\//#define QT_GUI_INLINE_SINCE(...) 0
        \\
        \\#define QT_NO_SHORTCUT
        \\#define QT_NO_ACTION
        \\
        \\#define QT_FEATURE_cxx17_filesystem 1
        \\#define QT_FEATURE_signaling_nan 1
        \\#define QT_FEATURE_xcb 1
        \\#define QT_FEATURE_wayland -1
        \\#define QT_FEATURE_wheelevent -1
        \\#define QT_FEATURE_action -1
        \\#define QT_FEATURE_tooltip -1
        \\#define QT_FEATURE_statustip -1
        \\#define QT_FEATURE_whatsthis -1
        \\#define QT_FEATURE_accessibility -1
        \\#define QT_FEATURE_shortcut -1
        \\#define QT_FEATURE_graphicseffect -1
        \\#define QT_FEATURE_graphicsview -1
        \\#define QT_FEATURE_tabletevent -1
        \\#define QT_FEATURE_draganddrop -1
        \\#define QT_FEATURE_gestures -1
        \\#define QT_FEATURE_spinbox -1
        \\#define QT_FEATURE_slider -1
        \\#define QT_FEATURE_tabbar -1
        \\#define QT_FEATURE_tabwidget -1
        \\#define QT_FEATURE_rubberband -1
        \\#define QT_FEATURE_itemviews -1
        \\#define QT_FEATURE_toolbar -1
        \\#define QT_FEATURE_std_atomic64 -1
        \\#define QT_FEATURE_regularexpression -1
        \\#define QT_FEATURE_easingcurve -1
        \\#define QT_FEATURE_itemmodel -1
        \\#define QT_FEATURE_future -1
        \\#define QT_FEATURE_permissions -1
        \\#define QT_FEATURE_library -1
        \\#define QT_FEATURE_timezone -1
        \\#define QT_FEATURE_datestring -1
        \\#define QT_FEATURE_jalalicalendar -1
        \\#define QT_FEATURE_islamiccivilcalendar -1
        \\
        \\#define QT_FEATURE_abstractbutton 1
        \\#define QT_FEATURE_buttongroup -1
        \\#define QT_FEATURE_menu -1
        \\#define QT_FEATURE_pushbutton 1
        \\
    );
    _ = write_files.add("QtCore/private/qconfig_p.h", "");
    _ = write_files.add("QtCore/qtcore-config.h", "");
    _ = write_files.add("QtCore/private/qtcore-config_p.h", "");
    _ = write_files.add("QtCore/qtcoreexports.h", "#define Q_CORE_EXPORT");
    _ = write_files.add("QtGui/qtgui-config.h", "");
    _ = write_files.add("QtGui/private/qtgui-config_p.h", "");
    _ = write_files.add("QtGui/qtguiexports.h", "#define Q_GUI_EXPORT");
    _ = write_files.add("QtWidgets/qtwidgets-config.h", "");
    _ = write_files.add("QtWidgets/qtwidgetsexports.h", "#define Q_WIDGETS_EXPORT");
    _ = write_files.addCopyDirectory(
        qtbase_dep.path("mkspecs"),
        "mkspecs",
        .{ },
    );
    const qt = b.addStaticLibrary(.{
        .name = "qt",
        .target = target,
        .optimize = optimize,
    });
    qt.addIncludePath(write_files.getDirectory());
    switch (target.result.os.tag) {
        .linux => qt.addIncludePath(
            write_files.getDirectory().path(b, "mkspecs/linux-clang"),
        ),
        .macos => qt.addIncludePath(
            write_files.getDirectory().path(b, "mkspecs/macx-clang"),
        ),
        else => {},
    }
    qt.installHeadersDirectory(write_files.getDirectory(), "", .{});
    qt.addIncludePath(core_inc.path(b, "."));
    qt.addIncludePath(core_inc.path(b, "QtCore"));
    qt.installHeadersDirectory(core_inc.path(b, "."), "", .{.include_extensions = &.{""}});
    qt.addIncludePath(gui_inc.path(b, "."));
    qt.addIncludePath(gui_inc.path(b, "QtGui"));
    qt.installHeadersDirectory(gui_inc.path(b, "."), "", .{.include_extensions = &.{""}});
    qt.addIncludePath(widgets_inc.path(b, "."));
    qt.addIncludePath(widgets_inc.path(b, "QtWidgets"));
    qt.installHeadersDirectory(widgets_inc.path(b, "."), "", .{.include_extensions = &.{""}});
    qt.addCSourceFiles(.{
        .root = qtbase_dep.path("."),
        .files = &.{
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            "blank.cpp",
            "src/widgets/kernel/qapplication.cpp",
        },
        .flags = &.{
            "-std=c++23",
        },
    });
    qt.linkLibCpp();

    {
        const exe = b.addExecutable(.{
            .name = "helloqt",
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(qt);

        const qt_header_tree = qt.installed_headers_include_tree.?;
        exe.addIncludePath(qt_header_tree.getDirectory().path(b, "QtGui"));
        exe.addIncludePath(qt_header_tree.getDirectory().path(b, "QtWidgets"));
        exe.addCSourceFiles(.{
            .files = &.{ "helloqt.cpp" },
        });
        exe.linkLibCpp();
        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("hello", "Run the helloqt app");
        run_step.dependOn(&run_cmd.step);
    }

    if (false) {
        const exe = b.addExecutable(.{
            .name = "ladybird",
            .target = target,
            .optimize = optimize,
        });
        exe.addIncludePath(b.path("."));
        exe.addIncludePath(b.path("Userland/Libraries"));
        exe.addIncludePath(core_inc);
        exe.addIncludePath(core_inc.path(b, "QtCore"));
        exe.addCSourceFiles(.{
            .files = &files,
            .flags = &.{
                "-std=c++23",
                //"-fsigned-char",
                //"-fconcepts",
                //"-fno-exceptions",
                //"-fno-semantic-interposition",
                //"-fPIC",
                "-fpermissive",
                "-Wno-error=reserved-user-defined-literal",
            },
        });
        exe.linkLibCpp();
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}

const files = [_][]const u8 {
    "Ladybird/Qt/Application.cpp",
    "Ladybird/Qt/AutoComplete.cpp",
    "Ladybird/Qt/BrowserWindow.cpp",
    "Ladybird/Qt/EventLoopImplementationQt.cpp",
    "Ladybird/Qt/EventLoopImplementationQtEventTarget.cpp",
    "Ladybird/Qt/FindInPageWidget.cpp",
    "Ladybird/Qt/Icon.cpp",
    "Ladybird/Qt/InspectorWidget.cpp",
    "Ladybird/Qt/LocationEdit.cpp",
    "Ladybird/Qt/Settings.cpp",
    "Ladybird/Qt/SettingsDialog.cpp",
    "Ladybird/Qt/Tab.cpp",
    "Ladybird/Qt/TabBar.cpp",
    "Ladybird/Qt/TaskManagerWindow.cpp",
    "Ladybird/Qt/TVGIconEngine.cpp",
    "Ladybird/Qt/StringUtils.cpp",
    "Ladybird/Qt/WebContentView.cpp",
    //"Ladybird/Qt/ladybird.qrc"
    "Ladybird/Qt/main.cpp",
};

const Module = struct {
    name: []const u8,
    relative_dir: []const u8,
    sources: []const []const u8,
    // include_dirs
    // libs
    // precompiled_header
    // public libs

    pub fn makeSyncQt(
        comptime self: Module,
        b: *std.Build,
        qtbase_dep: *std.Build.Dependency,
        syncqt_exe: *std.Build.Step.Compile,
    ) std.Build.LazyPath {
        const qt_name = "Qt" ++ self.name;
        const sync = b.addRunArtifact(syncqt_exe);
        sync.addArg("-module");
        sync.addArg(qt_name);
        sync.addArg("-sourceDir");
        sync.addDirectoryArg(qtbase_dep.path(self.relative_dir));
        sync.addArg("-binaryDir");
        _ = sync.addOutputDirectoryArg(qt_name ++ "_bin");
        sync.addArg("-privateHeadersFilter");
        sync.addArg(".+_p(ch)?\\.h");
        sync.addArg("-includeDir");
        const pub_inc_dir = sync.addOutputDirectoryArg(qt_name);
        sync.addArg("-privateIncludeDir");
        _ = sync.addOutputDirectoryArg(qt_name ++ "/private");
        sync.addArg("-qpaIncludeDir");
        _ = sync.addOutputDirectoryArg(qt_name ++ "/qpa");
        sync.addArg("-rhiIncludeDir");
        _ = sync.addOutputDirectoryArg(qt_name ++ "/rhi");
        sync.addArg("-ssgIncludeDir");
        _ = sync.addOutputDirectoryArg(qt_name ++ "/ssg");
        // -generatedHeaders?
        sync.addArg("-headers");
        for (self.sources) |src| {

            //if (std.mem.endsWith(u8, src, ".h") and !std.mem.endsWith(u8, src, "_p.h")) {
            if (std.mem.endsWith(u8, src, ".h")) {
                sync.addArg(src);
            }
        }
        return pub_inc_dir.dirname();
    }

};

const module_core = Module{
    .name = "Core",
    .relative_dir = "src/corelib",
    .sources = &.{
        // Keep these .cpp files in the first and in the order they are so their
        // static initialization order is retained
        "global/qsimd.cpp", "global/qsimd.h", "global/qsimd_p.h",
        "tools/qhash.cpp", "tools/qhash.h",

        // Keep the rest alphabetical
        "compat/removed_api.cpp",
        "global/archdetect.cpp",
        "global/qassert.cpp", "global/qassert.h",
        "global/qcompare_impl.h",
        "global/qcompare.cpp", "global/qcompare.h",
        "global/qcomparehelpers.h",
        "global/qcompilerdetection.h",
        "global/qconstructormacros.h",
        "global/qcontainerinfo.h",
        "global/qdarwinhelpers.h",
        "global/qendian.cpp", "global/qendian.h", "global/qendian_p.h",
        "global/qexceptionhandling.cpp", "global/qexceptionhandling.h",
        "global/qflags.h",
        "global/qfloat16.cpp", "global/qfloat16.h",
        "global/qforeach.h",
        "global/qfunctionpointer.h",
        "global/qglobal.cpp", "global/qglobal.h", "global/qglobal_p.h",
        "global/qglobalstatic.h",
        "global/qhooks.cpp", "global/qhooks_p.h",
        "global/qlibraryinfo.cpp", "global/qlibraryinfo.h", "global/qlibraryinfo_p.h",
        "global/qlogging.cpp", "global/qlogging.h", "global/qlogging_p.h",
        "global/qmalloc.cpp", "global/qmalloc.h",
        "global/qminmax.h",
        "global/qnamespace.h", // this header is specified on purpose so AUTOMOC processes it
        "global/qnativeinterface.h", "global/qnativeinterface_p.h",
        "global/qnumeric.cpp", "global/qnumeric.h", "global/qnumeric_p.h",
        "global/qoperatingsystemversion.cpp", "global/qoperatingsystemversion.h", "global/qoperatingsystemversion_p.h",
        "global/qoverload.h",
        "global/qprocessordetection.h",
        "global/qrandom.cpp", "global/qrandom.h", "global/qrandom_p.h",
        "global/qswap.h",
        "global/qsysinfo.cpp", "global/qsysinfo.h",
        "global/qsystemdetection.h",
        "global/qtclasshelpermacros.h",
        "global/qtconfiginclude.h",
        "global/qtconfigmacros.h",
        "global/qtdeprecationmarkers.h",
        "global/qtenvironmentvariables.cpp", "global/qtenvironmentvariables.h",
        "global/qtenvironmentvariables_p.h",
        "global/qtnoop.h",
        "global/qtpreprocessorsupport.h",
        "global/qtrace_p.h",
        "global/qtresource.h",
        "global/qtsymbolmacros.h",
        "global/qttranslation.h",
        "global/qttypetraits.h",
        "global/qtversionchecks.h",
        "global/qtversion.h",
        "global/qtypeinfo.h",
        "global/qtypes.cpp", "global/qtypes.h",
        "global/qvolatile_p.h",
        "global/q20algorithm.h",
        "global/q20chrono.h",
        "global/q20functional.h",
        "global/q20iterator.h",
        "global/q20map.h",
        "global/q20memory.h",
        "global/q20type_traits.h",
        "global/q20vector.h",
        "global/q23functional.h",
        "global/q23utility.cpp", // remove once we have a user that tests this
        "global/q23utility.h",
        "global/qxpfunctional.h",
        "global/qxptype_traits.h",
        "ipc/qsharedmemory.cpp", "ipc/qsharedmemory.h", "ipc/qsharedmemory_p.h",
        "ipc/qsystemsemaphore.cpp", "ipc/qsystemsemaphore.h", "ipc/qsystemsemaphore_p.h",
        "ipc/qtipccommon.cpp", "ipc/qtipccommon.h", "ipc/qtipccommon_p.h",
        "io/qabstractfileengine.cpp", "io/qabstractfileengine_p.h",
        "io/qbuffer.cpp", "io/qbuffer.h",
        "io/qdataurl.cpp", "io/qdataurl_p.h",
        "io/qdebug.cpp", "io/qdebug.h", "io/qdebug_p.h",
        "io/qdir.cpp", "io/qdir.h", "io/qdir_p.h",
        "io/qdiriterator.cpp", "io/qdiriterator.h",
        "io/qfile.cpp", "io/qfile.h", "io/qfile_p.h",
        "io/qfiledevice.cpp", "io/qfiledevice.h", "io/qfiledevice_p.h",
        "io/qfileinfo.cpp", "io/qfileinfo.h", "io/qfileinfo_p.h",
        "io/qfileselector.cpp", "io/qfileselector.h", "io/qfileselector_p.h",
        "io/qfilesystemengine.cpp", "io/qfilesystemengine_p.h",
        "io/qfilesystementry.cpp", "io/qfilesystementry_p.h",
        "io/qfilesystemiterator_p.h",
        "io/qfilesystemmetadata_p.h",
        "io/qfsfileengine.cpp", "io/qfsfileengine_p.h",
        "io/qfsfileengine_iterator.cpp", "io/qfsfileengine_iterator_p.h",
        "io/qiodevice.cpp", "io/qiodevice.h", "io/qiodevice_p.h",
        "io/qiodevicebase.h",
        "io/qipaddress.cpp", "io/qipaddress_p.h",
        "io/qlockfile.cpp", "io/qlockfile.h", "io/qlockfile_p.h",
        "io/qloggingcategory.cpp", "io/qloggingcategory.h",
        "io/qloggingregistry.cpp", "io/qloggingregistry_p.h",
        "io/qnoncontiguousbytedevice.cpp", "io/qnoncontiguousbytedevice_p.h",
        "io/qresource.cpp", "io/qresource.h", "io/qresource_p.h",
        "io/qresource_iterator.cpp", "io/qresource_iterator_p.h",
        "io/qsavefile.cpp", "io/qsavefile.h", "io/qsavefile_p.h",
        "io/qstandardpaths.cpp", "io/qstandardpaths.h",
        "io/qstorageinfo.cpp", "io/qstorageinfo.h", "io/qstorageinfo_p.h",
        "io/qtemporarydir.cpp", "io/qtemporarydir.h",
        "io/qtemporaryfile.cpp", "io/qtemporaryfile.h", "io/qtemporaryfile_p.h",
        "io/qurl.cpp", "io/qurl.h", "io/qurl_p.h",
        "io/qurlidna.cpp",
        "io/qurlquery.cpp", "io/qurlquery.h",
        "io/qurlrecode.cpp",
        "io/qzipreader_p.h", "io/qzipwriter_p.h", "io/qzip.cpp",
        "kernel/qabstracteventdispatcher.cpp", "kernel/qabstracteventdispatcher.h", "kernel/qabstracteventdispatcher_p.h",
        "kernel/qabstractnativeeventfilter.cpp", "kernel/qabstractnativeeventfilter.h",
        "kernel/qapplicationstatic.h",
        "kernel/qassociativeiterable.cpp", "kernel/qassociativeiterable.h",
        "kernel/qbasictimer.cpp", "kernel/qbasictimer.h",
        "kernel/qbindingstorage.h",
        "kernel/qcoreapplication.cpp", "kernel/qcoreapplication.h", "kernel/qcoreapplication_p.h",
        "kernel/qcoreapplication_platform.h",
        "kernel/qcorecmdlineargs_p.h",
        "kernel/qcoreevent.cpp", "kernel/qcoreevent.h", "kernel/qcoreevent_p.h",
        "kernel/qdeadlinetimer.cpp", "kernel/qdeadlinetimer.h",
        "kernel/qelapsedtimer.cpp", "kernel/qelapsedtimer.h",
        "kernel/qeventloop.cpp", "kernel/qeventloop.h", "kernel/qeventloop_p.h",
        "kernel/qfunctions_p.h",
        "kernel/qiterable.cpp", "kernel/qiterable.h", "kernel/qiterable_p.h",
        "kernel/qmath.cpp", "kernel/qmath.h",
        "kernel/qmetacontainer.cpp", "kernel/qmetacontainer.h",
        "kernel/qmetaobject.cpp", "kernel/qmetaobject.h", "kernel/qmetaobject_p.h",
        "kernel/qmetaobject_moc_p.h",
        "kernel/qmetaobjectbuilder.cpp", "kernel/qmetaobjectbuilder_p.h",
        "kernel/qmetatype.cpp", "kernel/qmetatype.h", "kernel/qmetatype_p.h",
        "kernel/qmimedata.cpp", "kernel/qmimedata.h",
        "kernel/qtmetamacros.h", "kernel/qtmochelpers.h",
        "kernel/qobject.cpp", "kernel/qobject.h", "kernel/qobject_p.h", "kernel/qobject_p_p.h",
        "kernel/qobject_impl.h",
        "kernel/qobjectcleanuphandler.cpp", "kernel/qobjectcleanuphandler.h",
        "kernel/qobjectdefs.h",
        "kernel/qobjectdefs_impl.h",
        "kernel/qpointer.h",
        "kernel/qproperty.cpp", "kernel/qproperty.h", "kernel/qproperty_p.h",
        "kernel/qpropertyprivate.h",
        "kernel/qsequentialiterable.cpp", "kernel/qsequentialiterable.h",
        "kernel/qsignalmapper.cpp", "kernel/qsignalmapper.h",
        "kernel/qsocketnotifier.cpp", "kernel/qsocketnotifier.h",
        "kernel/qsystemerror.cpp", "kernel/qsystemerror_p.h",
        "kernel/qtestsupport_core.cpp", "kernel/qtestsupport_core.h",
        "kernel/qsingleshottimer_p.h",
        "kernel/qtimer.cpp", "kernel/qtimer.h", "kernel/qtimer_p.h",
        "kernel/qtranslator.cpp", "kernel/qtranslator.h", "kernel/qtranslator_p.h",
        "kernel/qvariant.cpp", "kernel/qvariant.h", "kernel/qvariant_p.h",
        "kernel/qvariantmap.h", "kernel/qvarianthash.h", "kernel/qvariantlist.h",
        "plugin/qfactoryinterface.cpp", "plugin/qfactoryinterface.h",
        "plugin/qfactoryloader.cpp", "plugin/qfactoryloader_p.h",
        "plugin/qplugin.h", "plugin/qplugin_p.h",
        "plugin/qpluginloader.cpp", "plugin/qpluginloader.h",
        "plugin/quuid.cpp", "plugin/quuid.h",
        "serialization/qcborarray.h",
        "serialization/qcborcommon.cpp", "serialization/qcborcommon.h", "serialization/qcborcommon_p.h",
        "serialization/qcbordiagnostic.cpp",
        "serialization/qcbormap.h",
        "serialization/qcborstream.h",
        "serialization/qcborvalue.cpp", "serialization/qcborvalue.h", "serialization/qcborvalue_p.h",
        "serialization/qdatastream.cpp", "serialization/qdatastream.h", "serialization/qdatastream_p.h",
        "serialization/qjson_p.h",
        "serialization/qjsonarray.cpp", "serialization/qjsonarray.h",
        "serialization/qjsoncbor.cpp",
        "serialization/qjsondocument.cpp", "serialization/qjsondocument.h",
        "serialization/qjsonobject.cpp", "serialization/qjsonobject.h",
        "serialization/qjsonparser.cpp", "serialization/qjsonparser_p.h",
        "serialization/qjsonvalue.cpp", "serialization/qjsonvalue.h",
        "serialization/qjsonwriter.cpp", "serialization/qjsonwriter_p.h",
        "serialization/qtextstream.cpp", "serialization/qtextstream.h", "serialization/qtextstream_p.h",
        "serialization/qxmlutils.cpp", "serialization/qxmlutils_p.h",
        "text/qanystringview.cpp", "text/qanystringview.h",
        "text/qbytearray.cpp", "text/qbytearray.h", "text/qbytearray_p.h",
        "text/qbytearrayalgorithms.h",
        "text/qbytearraylist.cpp", "text/qbytearraylist.h",
        "text/qbytearraymatcher.cpp", "text/qbytearraymatcher.h",
        "text/qbytearrayview.h",
        "text/qbytedata_p.h",
        "text/qchar.h",
        "text/qcollator.cpp", "text/qcollator.h", "text/qcollator_p.h",
        "text/qdoublescanprint_p.h",
        "text/qlatin1stringmatcher.cpp", "text/qlatin1stringmatcher.h",
        "text/qlatin1stringview.h",
        "text/qlocale.cpp", "text/qlocale.h", "text/qlocale_p.h",
        "text/qlocale_data_p.h",
        "text/qlocale_tools.cpp", "text/qlocale_tools_p.h",
        "text/qstaticlatin1stringmatcher.h",
        "text/qstring.cpp", "text/qstring.h",
        "text/qstringalgorithms.h", "text/qstringalgorithms_p.h",
        "text/qstringbuilder.cpp", "text/qstringbuilder.h",
        "text/qstringconverter_base.h",
        "text/qstringconverter.cpp", "text/qstringconverter.h", "text/qstringconverter_p.h",
        "text/qstringfwd.h",
        "text/qstringiterator_p.h",
        "text/qstringlist.cpp", "text/qstringlist.h",
        "text/qstringliteral.h",
        "text/qstringmatcher.h",
        "text/qstringtokenizer.cpp", "text/qstringtokenizer.h",
        "text/qstringview.cpp", "text/qstringview.h",
        "text/qtextboundaryfinder.cpp", "text/qtextboundaryfinder.h",
        "text/qunicodetables_p.h",
        "text/qunicodetools.cpp", "text/qunicodetools_p.h",
        "text/qutf8stringview.h",
        "text/qvsnprintf.cpp",
        "thread/qatomic.h",
        "thread/qatomic_cxx11.h",
        "thread/qbasicatomic.h",
        "thread/qgenericatomic.h",
        "thread/qlocking_p.h",
        "thread/qmutex.h",
        "thread/qorderedmutexlocker_p.h",
        "thread/qreadwritelock.h",
        "thread/qrunnable.cpp", "thread/qrunnable.h",
        "thread/qthread.cpp", "thread/qthread.h", "thread/qthread_p.h",
        "thread/qthreadstorage.h",
        "thread/qtsan_impl.h",
        "thread/qwaitcondition.h", "thread/qwaitcondition_p.h",
        "thread/qyieldcpu.h",
        "time/qcalendar.cpp", "time/qcalendar.h",
        "time/qcalendarbackend_p.h",
        "time/qcalendarmath_p.h",
        "time/qdatetime.cpp", "time/qdatetime.h", "time/qdatetime_p.h",
        "time/qgregoriancalendar.cpp", "time/qgregoriancalendar_p.h",
        "time/qjuliancalendar.cpp", "time/qjuliancalendar_p.h",
        "time/qlocaltime.cpp", "time/qlocaltime_p.h",
        "time/qmilankoviccalendar.cpp", "time/qmilankoviccalendar_p.h",
        "time/qromancalendar.cpp", "time/qromancalendar_p.h",
        "time/qromancalendar_data_p.h",
        "time/qtimezone.cpp", "time/qtimezone.h",
        "tools/qalgorithms.h",
        "tools/qarraydata.cpp", "tools/qarraydata.h",
        "tools/qarraydataops.h",
        "tools/qarraydatapointer.h",
        "tools/qatomicscopedvaluerollback.h",
        "tools/qbitarray.cpp", "tools/qbitarray.h",
        "tools/qcache.h",
        "tools/qcontainerfwd.h",
        "tools/qcontainertools_impl.h",
        "tools/qcontiguouscache.cpp", "tools/qcontiguouscache.h",
        "tools/qcryptographichash.cpp", "tools/qcryptographichash.h",
        "tools/qduplicatetracker_p.h",
        "tools/qflatmap_p.h",
        "tools/qfreelist.cpp", "tools/qfreelist_p.h",
        "tools/qfunctionaltools_impl.cpp", "tools/qfunctionaltools_impl.h",
        "tools/qhashfunctions.h",
        "tools/qiterator.h",
        "tools/qline.cpp", "tools/qline.h",
        "tools/qlist.h",
        "tools/qmakearray_p.h",
        "tools/qmap.h",
        "tools/qmargins.cpp", "tools/qmargins.h",
        "tools/qmessageauthenticationcode.h",
        "tools/qoffsetstringarray_p.h",
        "tools/qpair.h",
        "tools/qpoint.cpp", "tools/qpoint.h",
        "tools/qqueue.h",
        "tools/qrect.cpp", "tools/qrect.h",
        "tools/qrefcount.cpp", "tools/qrefcount.h",
        "tools/qringbuffer.cpp", "tools/qringbuffer_p.h",
        "tools/qscopedpointer.h",
        "tools/qscopedvaluerollback.h",
        "tools/qscopeguard.h",
        "tools/qset.h",
        "tools/qshareddata.cpp", "tools/qshareddata.h",
        "tools/qshareddata_impl.h",
        "tools/qsharedpointer.cpp", "tools/qsharedpointer.h",
        "tools/qsharedpointer_impl.h",
        "tools/qsize.cpp", "tools/qsize.h",
        "tools/qspan.h",
        "tools/qspan_p.h",
        "tools/qstack.h",
        "tools/qtaggedpointer.h",
        "tools/qtools_p.h",
        "tools/qtyperevision.cpp", "tools/qtyperevision.h",
        "tools/quniquehandle_p.h",
        "tools/qvarlengtharray.h",
        "tools/qvector.h",
        "tools/qversionnumber.cpp", "tools/qversionnumber.h",
        //NO_UNITY_BUILD_SOURCES
        // MinGW complains about `free-nonheap-object` in ~QSharedDataPointer()
        // despite the fact that appropriate checks are in place to avoid that!
        "tools/qshareddata.cpp", "tools/qshareddata.h",
        "text/qlocale.cpp", "text/qlocale.h",
        "global/qglobal.cpp",  // undef qFatal
        "global/qlogging.cpp", // undef qFatal/qInfo/qDebug
        "global/qrandom.cpp", // undef Q_ASSERT/_X
        "text/qstringconverter.cpp", // enum Data
        "tools/qcryptographichash.cpp", // KeccakNISTInterface/Final
        "io/qdebug.cpp", // undef qDebug
        // NO_PCH_SOURCES
        "compat/removed_api.cpp",
        "global/qsimd.cpp",
        // Missing???
        "global/qversiontagging.h",
    },
};

const module_gui = Module{
    .name = "Gui",
    .relative_dir = "src/gui",
    .sources = &.{
        "compat/removed_api.cpp",
        "image/qabstractfileiconengine.cpp", "image/qabstractfileiconengine_p.h",
        "image/qabstractfileiconprovider.cpp", "image/qabstractfileiconprovider.h", "image/qabstractfileiconprovider_p.h",
        "image/qbitmap.cpp", "image/qbitmap.h",
        "image/qbmphandler.cpp", "image/qbmphandler_p.h",
        "image/qicon.cpp", "image/qicon.h", "image/qicon_p.h",
        "image/qiconengine.cpp", "image/qiconengine.h", "image/qiconengine_p.h",
        "image/qiconengineplugin.cpp", "image/qiconengineplugin.h",
        "image/qiconloader.cpp", "image/qiconloader_p.h",
        "image/qimage.cpp", "image/qimage.h", "image/qimage_p.h",
        "image/qimage_conversions.cpp",
        "image/qimageiohandler.cpp", "image/qimageiohandler.h",
        "image/qimagepixmapcleanuphooks.cpp", "image/qimagepixmapcleanuphooks_p.h",
        "image/qimagereader.cpp", "image/qimagereader.h",
        "image/qimagereaderwriterhelpers.cpp", "image/qimagereaderwriterhelpers_p.h",
        "image/qimagewriter.cpp", "image/qimagewriter.h",
        "image/qpaintengine_pic.cpp", "image/qpaintengine_pic_p.h",
        "image/qpicture.cpp", "image/qpicture.h", "image/qpicture_p.h",
        "image/qpixmap.cpp", "image/qpixmap.h",
        "image/qpixmap_blitter.cpp", "image/qpixmap_blitter_p.h",
        "image/qpixmap_raster.cpp", "image/qpixmap_raster_p.h",
        "image/qpixmapcache.cpp", "image/qpixmapcache.h", "image/qpixmapcache_p.h",
        "image/qplatformpixmap.cpp", "image/qplatformpixmap.h",
        "image/qppmhandler.cpp", "image/qppmhandler_p.h",
        "image/qxbmhandler.cpp", "image/qxbmhandler_p.h",
        "image/qxpmhandler.cpp", "image/qxpmhandler_p.h",
        "kernel/qclipboard.cpp", "kernel/qclipboard.h",
        "kernel/qcursor.cpp", "kernel/qcursor.h", "kernel/qcursor_p.h",
        "kernel/qeventpoint.cpp", "kernel/qeventpoint.h", "kernel/qeventpoint_p.h",
        "kernel/qevent.cpp", "kernel/qevent.h", "kernel/qevent_p.h",
        "kernel/qgenericplugin.cpp", "kernel/qgenericplugin.h",
        "kernel/qgenericpluginfactory.cpp", "kernel/qgenericpluginfactory.h",
        "kernel/qguiapplication.cpp", "kernel/qguiapplication.h", "kernel/qguiapplication_p.h", "kernel/qguiapplication_platform.h",
        "kernel/qguivariant.cpp",
        "kernel/qhighdpiscaling.cpp", "kernel/qhighdpiscaling_p.h",
        "kernel/qinputdevice.cpp", "kernel/qinputdevice.h", "kernel/qinputdevice_p.h",
        "kernel/qinputdevicemanager.cpp", "kernel/qinputdevicemanager_p.h",
        "kernel/qinputdevicemanager_p_p.h",
        "kernel/qinputmethod.cpp", "kernel/qinputmethod.h", "kernel/qinputmethod_p.h",
        "kernel/qinternalmimedata.cpp", "kernel/qinternalmimedata_p.h",
        "kernel/qkeymapper.cpp", "kernel/qkeymapper_p.h",
        "kernel/qoffscreensurface.cpp", "kernel/qoffscreensurface.h", "kernel/qoffscreensurface_p.h",
        "kernel/qoffscreensurface_platform.h",
        "kernel/qopenglcontext.h",
        "kernel/qpaintdevicewindow.cpp", "kernel/qpaintdevicewindow.h", "kernel/qpaintdevicewindow_p.h",
        "kernel/qpalette.cpp", "kernel/qpalette.h", "kernel/qpalette_p.h",
        "kernel/qpixelformat.cpp", "kernel/qpixelformat.h",
        "kernel/qplatformclipboard.cpp", "kernel/qplatformclipboard.h",
        "kernel/qplatformcursor.cpp", "kernel/qplatformcursor.h",
        "kernel/qplatformdialoghelper.cpp", "kernel/qplatformdialoghelper.h",
        "kernel/qplatformgraphicsbuffer.cpp", "kernel/qplatformgraphicsbuffer.h",
        "kernel/qplatformgraphicsbufferhelper.cpp", "kernel/qplatformgraphicsbufferhelper.h",
        "kernel/qplatforminputcontext.cpp", "kernel/qplatforminputcontext.h", "kernel/qplatforminputcontext_p.h",
        "kernel/qplatforminputcontextfactory.cpp", "kernel/qplatforminputcontextfactory_p.h",
        "kernel/qplatforminputcontextplugin.cpp", "kernel/qplatforminputcontextplugin_p.h",
        "kernel/qplatformintegration.cpp", "kernel/qplatformintegration.h",
        "kernel/qplatformintegrationfactory.cpp", "kernel/qplatformintegrationfactory_p.h",
        "kernel/qplatformintegrationplugin.cpp", "kernel/qplatformintegrationplugin.h",
        "kernel/qplatformkeymapper.cpp", "kernel/qplatformkeymapper.h",
        "kernel/qplatformmenu.cpp", "kernel/qplatformmenu.h", "kernel/qplatformmenu_p.h",
        "kernel/qplatformnativeinterface.cpp", "kernel/qplatformnativeinterface.h",
        "kernel/qplatformoffscreensurface.cpp", "kernel/qplatformoffscreensurface.h",
        "kernel/qplatformopenglcontext.h",
        "kernel/qplatformscreen.cpp", "kernel/qplatformscreen.h", "kernel/qplatformscreen_p.h",
        "kernel/qplatformservices.cpp", "kernel/qplatformservices.h",
        "kernel/qplatformsessionmanager.cpp", "kernel/qplatformsessionmanager.h",
        "kernel/qplatformsharedgraphicscache.cpp", "kernel/qplatformsharedgraphicscache.h",
        "kernel/qplatformsurface.cpp", "kernel/qplatformsurface.h",
        "kernel/qplatformsystemtrayicon.cpp", "kernel/qplatformsystemtrayicon.h",
        "kernel/qplatformtheme.cpp", "kernel/qplatformtheme.h", "kernel/qplatformtheme_p.h",
        "kernel/qplatformthemefactory.cpp", "kernel/qplatformthemefactory_p.h",
        "kernel/qplatformthemeplugin.cpp", "kernel/qplatformthemeplugin.h",
        "kernel/qplatformwindow.cpp", "kernel/qplatformwindow.h", "kernel/qplatformwindow_p.h",
        "kernel/qpointingdevice.cpp", "kernel/qpointingdevice.h", "kernel/qpointingdevice_p.h",
        "kernel/qrasterwindow.cpp", "kernel/qrasterwindow.h",
        "kernel/qscreen.cpp", "kernel/qscreen.h", "kernel/qscreen_p.h", "kernel/qscreen_platform.h",
        "kernel/qsessionmanager.cpp", "kernel/qsessionmanager.h", "kernel/qsessionmanager_p.h",
        "kernel/qstylehints.cpp", "kernel/qstylehints.h", "kernel/qstylehints_p.h",
        "kernel/qsurface.cpp", "kernel/qsurface.h",
        "kernel/qsurfaceformat.cpp", "kernel/qsurfaceformat.h",
        "kernel/qtestsupport_gui.cpp", "kernel/qtestsupport_gui.h",
        "kernel/qtguiglobal.h", "kernel/qtguiglobal_p.h",
        "kernel/qwindow.cpp", "kernel/qwindow.h", "kernel/qwindow_p.h",
        "kernel/qwindowdefs.h",
        "kernel/qwindowsysteminterface.cpp", "kernel/qwindowsysteminterface.h", "kernel/qwindowsysteminterface_p.h",
        "math3d/qgenericmatrix.cpp", "math3d/qgenericmatrix.h",
        "math3d/qmatrix4x4.cpp", "math3d/qmatrix4x4.h",
        "math3d/qquaternion.cpp", "math3d/qquaternion.h",
        "math3d/qvector2d.h",
        "math3d/qvector3d.h",
        "math3d/qvector4d.h",
        "math3d/qvectornd.cpp", "math3d/qvectornd.h",
        "opengl/qopengl.h",
        "opengl/qopenglext.h",
        "opengl/qopenglfunctions.h",
        "opengl/qopenglextrafunctions.h",
        "painting/qbackingstore.cpp", "painting/qbackingstore.h",
        "painting/qbackingstoredefaultcompositor.cpp", "painting/qbackingstoredefaultcompositor_p.h",
        "painting/qbackingstorerhisupport.cpp", "painting/qbackingstorerhisupport_p.h",
        "painting/qbezier.cpp", "painting/qbezier_p.h",
        "painting/qblendfunctions.cpp", "painting/qblendfunctions_p.h",
        "painting/qblittable.cpp", "painting/qblittable_p.h",
        "painting/qbrush.cpp", "painting/qbrush.h",
        "painting/qcolor.cpp", "painting/qcolor.h", "painting/qcolor_p.h",
        "painting/qcolormatrix_p.h",
        "painting/qcolorspace.cpp", "painting/qcolorspace.h", "painting/qcolorspace_p.h",
        "painting/qcolortransferfunction_p.h",
        "painting/qcolortransfertable_p.h",
        "painting/qcolortransform.cpp", "painting/qcolortransform.h", "painting/qcolortransform_p.h",
        "painting/qcolortrc_p.h",
        "painting/qcolortrclut.cpp", "painting/qcolortrclut_p.h",
        "painting/qcompositionfunctions.cpp",
        "painting/qcosmeticstroker.cpp", "painting/qcosmeticstroker_p.h",
        "painting/qdatabuffer_p.h",
        "painting/qdrawhelper_p.h",
        "painting/qdrawhelper_x86_p.h",
        "painting/qdrawingprimitive_sse2_p.h",
        "painting/qemulationpaintengine.cpp", "painting/qemulationpaintengine_p.h",
        "painting/qfixed_p.h",
        "painting/qgrayraster.c painting/qgrayraster_p.h",
        "painting/qicc.cpp", "painting/qicc_p.h",
        "painting/qimagescale.cpp", "painting/qimagescale_p.h",
        "painting/qmath_p.h",
        "painting/qmemrotate.cpp", "painting/qmemrotate_p.h",
        "painting/qoutlinemapper.cpp", "painting/qoutlinemapper_p.h",
        "painting/qpagedpaintdevice.cpp", "painting/qpagedpaintdevice.h", "painting/qpagedpaintdevice_p.h",
        "painting/qpagelayout.cpp", "painting/qpagelayout.h",
        "painting/qpageranges.cpp", "painting/qpageranges.h", "painting/qpageranges_p.h",
        "painting/qpagesize.cpp", "painting/qpagesize.h",
        "painting/qpaintdevice.cpp", "painting/qpaintdevice.h",
        "painting/qpaintengine.cpp", "painting/qpaintengine.h", "painting/qpaintengine_p.h",
        "painting/qpaintengine_blitter.cpp", "painting/qpaintengine_blitter_p.h",
        "painting/qpaintengine_raster.cpp", "painting/qpaintengine_raster_p.h",
        "painting/qpaintengineex.cpp", "painting/qpaintengineex_p.h",
        "painting/qpainter.cpp", "painting/qpainter.h", "painting/qpainter_p.h",
        "painting/qpainterpath.cpp", "painting/qpainterpath.h", "painting/qpainterpath_p.h",
        "painting/qpathclipper.cpp", "painting/qpathclipper_p.h",
        "painting/qpathsimplifier.cpp", "painting/qpathsimplifier_p.h",
        "painting/qpdf.cpp", "painting/qpdf_p.h",
        "painting/qpdfwriter.cpp", "painting/qpdfwriter.h",
        "painting/qpen.cpp", "painting/qpen.h", "painting/qpen_p.h",
        "painting/qpixellayout.cpp", "painting/qpixellayout_p.h",
        "painting/qplatformbackingstore.cpp", "painting/qplatformbackingstore.h",
        "painting/qpolygon.cpp", "painting/qpolygon.h",
        "painting/qrasterdefs_p.h",
        "painting/qrasterizer.cpp", "painting/qrasterizer_p.h",
        "painting/qrbtree_p.h",
        "painting/qregion.cpp", "painting/qregion.h",
        "painting/qrgb.h",
        "painting/qrgba64.h", "painting/qrgba64_p.h",
        "painting/qrgbafloat.h",
        "painting/qstroker.cpp", "painting/qstroker_p.h",
        "painting/qtextureglyphcache.cpp", "painting/qtextureglyphcache_p.h",
        "painting/qtransform.cpp", "painting/qtransform.h",
        "painting/qtriangulatingstroker.cpp", "painting/qtriangulatingstroker_p.h",
        "painting/qtriangulator.cpp", "painting/qtriangulator_p.h",
        "painting/qvectorpath_p.h",
        "rhi/qrhi.cpp", "rhi/qrhi.h", "rhi/qrhi_platform.h", "rhi/qrhi_p.h",
        "rhi/qrhinull.cpp", "rhi/qrhinull_p.h",
        "rhi/qshader.cpp", "rhi/qshader.h", "rhi/qshader_p.h",
        "rhi/qshaderdescription.cpp", "rhi/qshaderdescription.h", "rhi/qshaderdescription_p.h",
        "text/qabstracttextdocumentlayout.cpp", "text/qabstracttextdocumentlayout.h", "text/qabstracttextdocumentlayout_p.h",
        "text/qdistancefield.cpp", "text/qdistancefield_p.h",
        "text/qfont.cpp", "text/qfont.h", "text/qfont_p.h",
        "text/qfontdatabase.cpp", "text/qfontdatabase.h", "text/qfontdatabase_p.h",
        "text/qfontengine.cpp", "text/qfontengine_p.h",
        "text/qfontengineglyphcache.cpp", "text/qfontengineglyphcache_p.h",
        "text/qfontinfo.h",
        "text/qfontmetrics.cpp", "text/qfontmetrics.h",
        "text/qfontsubset.cpp", "text/qfontsubset_p.h",
        "text/qfragmentmap.cpp", "text/qfragmentmap_p.h",
        "text/qglyphrun.cpp", "text/qglyphrun.h", "text/qglyphrun_p.h",
        "text/qinputcontrol.cpp", "text/qinputcontrol_p.h",
        //"text/qplatformfontdatabase.cpp", "text/qplatformfontdatabase.h",
        "text/qrawfont.cpp", "text/qrawfont.h", "text/qrawfont_p.h",
        "text/qstatictext.cpp", "text/qstatictext.h", "text/qstatictext_p.h",
        "text/qsyntaxhighlighter.cpp", "text/qsyntaxhighlighter.h",
        "text/qtextcursor.cpp", "text/qtextcursor.h", "text/qtextcursor_p.h",
        "text/qtextdocument.cpp", "text/qtextdocument.h", "text/qtextdocument_p.cpp", "text/qtextdocument_p.h",
        "text/qtextdocumentfragment.cpp", "text/qtextdocumentfragment.h", "text/qtextdocumentfragment_p.h",
        "text/qtextdocumentlayout.cpp", "text/qtextdocumentlayout_p.h",
        "text/qtextdocumentwriter.cpp", "text/qtextdocumentwriter.h",
        "text/qtextengine.cpp", "text/qtextengine_p.h",
        "text/qtextformat.cpp", "text/qtextformat.h", "text/qtextformat_p.h",
        "text/qtexthtmlparser.cpp", "text/qtexthtmlparser_p.h",
        "text/qtextimagehandler.cpp", "text/qtextimagehandler_p.h",
        "text/qtextlayout.cpp", "text/qtextlayout.h",
        "text/qtextlist.cpp", "text/qtextlist.h",
        "text/qtextobject.cpp", "text/qtextobject.h", "text/qtextobject_p.h",
        "text/qtextoption.cpp", "text/qtextoption.h",
        "text/qtexttable.cpp", "text/qtexttable.h", "text/qtexttable_p.h",
        "util/qabstractlayoutstyleinfo.cpp", "util/qabstractlayoutstyleinfo_p.h",
        "util/qastchandler.cpp", "util/qastchandler_p.h",
        "util/qdesktopservices.cpp", "util/qdesktopservices.h",
        "util/qgridlayoutengine.cpp", "util/qgridlayoutengine_p.h",
        "util/qhexstring_p.h",
        "util/qktxhandler.cpp", "util/qktxhandler_p.h",
        "util/qlayoutpolicy.cpp", "util/qlayoutpolicy_p.h",
        "util/qpkmhandler.cpp", "util/qpkmhandler_p.h",
        "util/qtexturefiledata.cpp", "util/qtexturefiledata_p.h",
        "util/qtexturefilehandler_p.h",
        "util/qtexturefilereader.cpp", "util/qtexturefilereader_p.h",
        "util/qvalidator.cpp", "util/qvalidator.h",
    },
};

const module_widgets = Module{
    .name = "Widgets",
    .relative_dir = "src/widgets",
    .sources = &.{
        "compat/removed_api.cpp",
        "itemviews/qfileiconprovider.cpp", "itemviews/qfileiconprovider.h", "itemviews/qfileiconprovider_p.h",
        "kernel/qapplication.cpp", "kernel/qapplication.h", "kernel/qapplication_p.h",
        "kernel/qboxlayout.cpp", "kernel/qboxlayout.h",
        "kernel/qgesture.cpp", "kernel/qgesture.h", "kernel/qgesture_p.h",
        "kernel/qgesturemanager.cpp", "kernel/qgesturemanager_p.h",
        "kernel/qgesturerecognizer.cpp", "kernel/qgesturerecognizer.h",
        "kernel/qgridlayout.cpp", "kernel/qgridlayout.h",
        "kernel/qlayout.cpp", "kernel/qlayout.h", "kernel/qlayout_p.h",
        "kernel/qlayoutengine.cpp", "kernel/qlayoutengine_p.h",
        "kernel/qlayoutitem.cpp", "kernel/qlayoutitem.h",
        "kernel/qrhiwidget.cpp", "kernel/qrhiwidget.h", "kernel/qrhiwidget_p.h",
        "kernel/qsizepolicy.cpp", "kernel/qsizepolicy.h",
        "kernel/qstackedlayout.cpp", "kernel/qstackedlayout.h",
        "kernel/qstandardgestures.cpp", "kernel/qstandardgestures_p.h",
        "kernel/qtestsupport_widgets.cpp", "kernel/qtestsupport_widgets.h",
        "kernel/qtwidgetsglobal.h", "kernel/qtwidgetsglobal_p.h",
        "kernel/qwidget.cpp", "kernel/qwidget.h", "kernel/qwidget_p.h",
        "kernel/qwidgetrepaintmanager.cpp", "kernel/qwidgetrepaintmanager_p.h",
        "kernel/qwidgetsvariant.cpp",
        "kernel/qwidgetwindow.cpp", "kernel/qwidgetwindow_p.h",
        "kernel/qwindowcontainer.cpp", "kernel/qwindowcontainer_p.h",
        "styles/qcommonstyle.cpp", "styles/qcommonstyle.h", "styles/qcommonstyle_p.h",
        "styles/qcommonstylepixmaps_p.h",
        "styles/qdrawutil.cpp", "styles/qdrawutil.h",
        "styles/qpixmapstyle.cpp", "styles/qpixmapstyle_p.h",
        "styles/qpixmapstyle_p_p.h",
        "styles/qproxystyle.cpp", "styles/qproxystyle.h", "styles/qproxystyle_p.h",
        "styles/qstyle.cpp", "styles/qstyle.h", "styles/qstyle_p.h",
        "styles/qstylefactory.cpp", "styles/qstylefactory.h",
        "styles/qstylehelper.cpp", "styles/qstylehelper_p.h",
        "styles/qstyleoption.cpp", "styles/qstyleoption.h",
        "styles/qstylepainter.cpp", "styles/qstylepainter.h",
        "styles/qstyleplugin.cpp", "styles/qstyleplugin.h",
        "styles/qstylesheetstyle.cpp", "styles/qstylesheetstyle_p.h",
        "styles/qstylesheetstyle_default.cpp",
        "util/qcolormap.cpp", "util/qcolormap.h",
        "util/qsystemtrayicon.cpp", "util/qsystemtrayicon.h", "util/qsystemtrayicon_p.h",
        "widgets/qabstractscrollarea.cpp", "widgets/qabstractscrollarea.h", "widgets/qabstractscrollarea_p.h",
        "widgets/qfocusframe.cpp", "widgets/qfocusframe.h",
        "widgets/qframe.cpp", "widgets/qframe.h", "widgets/qframe_p.h",
        "widgets/qwidgetanimator.cpp", "widgets/qwidgetanimator_p.h",

        //qt_internal_extend_target(Widgets CONDITION QT_FEATURE_abstractbutton
        "widgets/qabstractbutton.cpp", "widgets/qabstractbutton.h", "widgets/qabstractbutton_p.h",

        //qt_internal_extend_target(Widgets CONDITION QT_FEATURE_pushbutton
        "widgets/qpushbutton.cpp", "widgets/qpushbutton.h", "widgets/qpushbutton_p.h",
    },
};
