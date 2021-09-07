Drupal.behaviors.streetmaps = {

attach: function(context) {
    function drawmap() {
        var latlng = new google.maps.LatLng(41.8819167,-87.669071);
        var myOptions = {
            zoom: 12,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById("map_canvas"),
            myOptions);
        var ftable = new google.maps.FusionTablesLayer({
            query: {
                select: "LOCATION",
                from: "1_8OKW77M_X6Ivuea-sCu1k50GEd89AzepmEi2vkZ",
                where : "FACILITYTYPE = 'OUTDOOR'"
            },
            styles: [{
                markerOptions: {
                    iconName: "small_yellow"
                }
            },
                {
                where: "FACILITYNAME IN ('POOL (OUTDOOR)','SPRAY FEATURE', 'WATER PLAYGROUND')",
                markerOptions: {
                    iconName: "measle_turquoise"
                }
            },
                {
                    where: "FACILITYNAME IN ('PLAYGROUND', 'PLAYGROUND PARK')",
                    markerOptions: {
                        iconName: "small_red"
                    }
                },
                {
                    where: "FACILITYNAME IN ('BASKETBALL COURT','TENNIS COURT','BASEBALLSR','FOOTBALL/SOCCER COMBO FLD','BASEBALL JR/SOFTBALL','VOLLEYBALL','TRACK')",
                    markerOptions: {
                        iconName: "small_green"
                    }
                },
                {
                    where: "FACILITYNAME IN ('GYMNASIUM','FITNESS CENTER','GARDEN','HORSESHOE COURT')",
                    markerOptions: {
                        iconName: "measle_brown"
                    }
                }

            ]
        });
        ftable.setMap(map);
        ftable.addListener('click', function(e){
            var parkname = e.row.PARK.value.toLowerCase();
            var pfirstname = parkname.match(/\((.*)\)/);
            if (pfirstname && pfirstname.length > 1) {
               parkname = pfirstname[1] + ' ' + parkname.replace((/\((.*)\)/), '');
            }
            var infostring = '<span class="ftinfowindow">' + parkname + ' Park<br/>' + e.row.FACILITYNAME.value.toLowerCase() + '</spanclass>';
            e.infoWindowHtml = '<div class="googft-info-window" style="width:300px;">'+infostring+'</div><div class="picgohere" style="height:240px;"> <div id="loadingthrobber"><i class="glyphicon glyphicon-refresh glyphicon-spin"></div>';
            var $locationpic = jQuery('<div id="svpanel" style="width:325px;height:280px;position:absolute"></div>');

            var pano;
            setTimeout( function() {
                jQuery('#loadingthrobber').remove();
                jQuery('.picgohere').append($locationpic);
                pano = new google.maps.StreetViewPanorama(
                    document.getElementById('svpanel'), {
                        position: e.latLng,
                        visible : true,
                        addressControl : false,
                        fullscreenControl : false,
                        enableCloseButton : false,
                        panControl : false,
                        motionTrackingControl : false,
                        linksControl : false,
                        zoomControl : false
                    }
                );
                console.log(jQuery('.widget-scene-imagery-render').css('display')) ;

            }, 2000);
        });

    }
    drawmap();

}

}