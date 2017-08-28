function setImageClickFunction(){
    
    var imgs = document.getElementsByTagName("img");
    
    for(var i=0;i<imgs.length;i++) {
        
        var src = imgs[i].src;
        
        img[i].onclick = function getImg(src){
            
            var url = src;
            
            document.location = url;
        }
    }
}


//function setImageClickFunction(cachePath){
//    
//    var imgs = document.getElementsByTagName("img");
//    
//    var count = 0;
//    
//    for(var i = 0; i < imgs.length; i++) {
//        
//        var src = imgs[i].src;
//        
//        imgs[i].setAttribute("onClick","getImg(src)");
//        
//        if (src.indexOf('https://static.oschina.net/uploads/space') > 0) {
//            
//            src.replace('https://static.oschina.net/uploads/space', cachePath);
//            
//            imgs[i].src = src;
//            
//            count ++;
//        };
//    }
//    
//    return count;
//}

