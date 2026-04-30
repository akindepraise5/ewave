Add-Type -AssemblyName System.Drawing
$images = Get-ChildItem -Path "pics\*.jpg"

foreach ($img in $images) {
    Write-Host "Compressing $($img.Name)..."
    $path = $img.FullName
    $image = [System.Drawing.Image]::FromFile($path)
    
    # Calculate new size (max 800x800)
    $maxSize = 800
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
    
    # Save as high-quality JPEG (Quality 70 to ensure good compression)
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 70L)
    
    # Overwrite original
    Remove-Item -Path $path -Force
    $newBmp.Save($path, $codec, $encoderParams)
    $newBmp.Dispose()
}
Write-Host "Compression complete!"
