Add-Type -AssemblyName System.Drawing
$folders = @("Assets", "Assets\Who it's for")

foreach ($folder in $folders) {
    $images = Get-ChildItem -Path "$folder\*.png"
    foreach ($img in $images) {
        Write-Host "Compressing $($img.Name) in $folder..."
        $path = $img.FullName
        $image = [System.Drawing.Image]::FromFile($path)
        
        # Calculate new size (max 1000px)
        $maxSize = 1000
        $ratioX = $maxSize / $image.Width
        $ratioY = $maxSize / $image.Height
        $ratio = [math]::Min($ratioX, $ratioY)
        
        if ($ratio -lt 1) {
            $newWidth = [int]($image.Width * $ratio)
            $newHeight = [int]($image.Height * $ratio)
        } else {
            $newWidth = $image.Width
            $newHeight = $image.Height
        }
        
        $newBmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newBmp)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
        
        $image.Dispose()
        $graphics.Dispose()
        
        # Overwrite original as a smaller PNG
        Remove-Item -Path $path -Force
        $newBmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        $newBmp.Dispose()
    }
}
Write-Host "Asset compression complete!"
