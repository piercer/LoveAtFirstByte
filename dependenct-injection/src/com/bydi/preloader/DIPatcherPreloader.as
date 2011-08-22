package com.bydi.preloader
{
    import com.bydi.patcher.DIPatcher;

    import org.mixingloom.managers.IPatchManager;
    import org.mixingloom.preloader.AbstractPreloader;

    public class DIPatcherPreloader extends AbstractPreloader
    {
        override protected function setupPatchers( manager:IPatchManager ):void
        {
            super.setupPatchers( manager );
            manager.registerPatcher( new DIPatcher() );
        }
    }
}
