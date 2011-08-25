package com.dz015.preloaders
{

    import com.dz015.patcher.Patcher;

    import org.mixingloom.managers.IPatchManager;
    import org.mixingloom.preloader.AbstractPreloader;

    public class AOPPreloader extends AbstractPreloader
    {

        override protected function setupPatchers( manager:IPatchManager ):void
        {
            super.setupPatchers( manager );
            manager.registerPatcher( new Patcher( "interceptors.xml" ) );
        }

    }
}