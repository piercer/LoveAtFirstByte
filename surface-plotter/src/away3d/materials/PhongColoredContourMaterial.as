package away3d.materials
{
    import away3d.textures.ContourMapTexture;

    public class PhongColoredContourMaterial extends PhongBitmapMaterial
    {
        public function PhongColoredContourMaterial()
        {

            var texture:ContourMapTexture = new ContourMapTexture();
            super( texture.texture );

        }
    }
}
