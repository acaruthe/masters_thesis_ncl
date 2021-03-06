
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
 ; The WRF ARW input file.
; This needs to have a ".nc" appended, so just do it.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; modern - pre
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
  type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"../../plots/modern_avg_precip")
 gsn_define_colormap(wks,"precip3_16lev")

 setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 300000000
  end setvalues

 mpGridAndLimbOn= True

; Set some basic resources
  res = True
  res@MainTitle                   = "REAL-TIME WRF"

  pltres = True
  mpres = True

mpGridAndLimbOn= True

mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
   mpres@mpGridLineColor        = "transparent"
   mpres@mpLimbLineColor        = "transparent"
   mpres@mpPerimLineColor       = "transparent"
  mpres@mpGeophysicalLineThicknessF = 2
  mpres@mpUSStateLineThicknessF = 2
  mpres@mpNationalLineThicknessF    = 2

pltres@PanelPlot = True      ; Indicate these plots are to be paneled.
res@NoHeaderFooter = True
pltres@NoTitles = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    

;loop thru each month (May-Aug)

m = (/0,1,2,3/)

aletters  = (/"May", "June", "July", "August"/)

month_string = stringtochar(aletters)

plots = new (4, graphic)

do ii = 0,0
   istart = 0 + ii*3
    iend = istart+3
    iplot = 0
do i = istart, iend

mon = m(i)
month = month_string(i,:)

letters  = (/"may", "june", "july", "august"/)

letters2 = (/"june", "july", "august", "sept"/)

monthss = (/"May", "June", "July", "August"/)

month_string = stringtochar(letters)

month2_string = stringtochar(letters2)

months_string = stringtochar(monthss)
do i = 0,3

month1 = month_string(i,:)

month2 = month2_string(i,:)

months = months_string(i,:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; the first month!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;may june july august
  mon1_pre = addfile("/glade/scratch/acaruth/NSF_CLM/presettle/"+month1+".nc","r")

  mon1_modern = addfile("/glade/scratch/acaruth/NSF_CLM/modernday/"+month1+".nc","r")


;;;;;;;;;;;;;;;;;;;;;;;;;;; the second month! ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; june july august sept
 mon2_pre = addfile("/glade/scratch/acaruth/NSF_CLM/presettle/"+month2+".nc","r")

 mon2_modern = addfile("/glade/scratch/acaruth/NSF_CLM/modernday/"+month2+".nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; What times and how many time steps are in the data set?
  FirstTime = True
  times = wrf_user_getvar(mon1_modern,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need
; modern

  ; Get non-convective, convective and total precipitation
  ; Calculate tendency values
    rain_exp_mon1_modern = wrf_user_getvar(mon1_modern,"RAINNC",-1)
    rain_con_mon1_modern = wrf_user_getvar(mon1_modern,"RAINC",-1)
	wrf_smooth_2d(rain_con_mon1_modern, 7)
        wrf_smooth_2d(rain_exp_mon1_modern, 7) 
    rain_tot_mon1_modern = rain_exp_mon1_modern + rain_con_mon1_modern
    rain_tot_mon1_modern@description = "Total Precipitation"


    rain_exp_mon2_modern = wrf_user_getvar(mon2_modern,"RAINNC",-1)
    rain_con_mon2_modern = wrf_user_getvar(mon2_modern,"RAINC",-1)
        wrf_smooth_2d(rain_con_mon2_modern, 7)
        wrf_smooth_2d(rain_exp_mon2_modern, 7)
     rain_tot_mon2_modern = rain_exp_mon2_modern + rain_con_mon2_modern
    rain_tot_mon2_modern@description = "Total Precipitation"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subtract precip to get monthly totals

rain_tot_modern = rain_tot_mon2_modern - rain_tot_mon1_modern

;average this stuff

rain_modern = dim_avg_n(rain_tot_modern(0::1,:,:), 0)

      ; Plotting options for Precipitation
        opts_r = res                        
        opts_r@cnInfoLabelOn        = False
        opts_r@cnConstFLabelOn      = False
	opts_r@lbLabelBarOn = False 
       opts_r@ContourParameters = (/0.,275., 25.0/)
       opts_r@cnFillOn             = True 
       contour_tot = wrf_contour(mon1_modern,wks,rain_modern, opts_r)
       delete(opts_r)


     mpres@tmXBLabelFontHeightF = 0.03
     mpres@tmYLLabelFontHeightF = 0.03
     plots(iplot) = wrf_map_overlays(mon1_modern,wks,(/contour_tot/),pltres,mpres)

         delete(contour_tot)
      iplot = iplot + 1

    end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;panel time ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    pnlres                            = True
    pnlres@txString                   = "Mean Total Precipitation (mm) ~C~~Z75~Modern Day ~C~~Z25~ "
    pnlres@txFontHeightF               = 0.025
    pnlres@gsnPanelYWhiteSpacePercent = 5       ; Add white space b/w plots.
    pnlres@gsnPanelLabelBar           = True    ; Turn on common labelbar
    pnlres@lbLabelAutoStride          = True    ; Spacing of lbar labels.
    pnlres@lbBoxMinorExtentF          = 0.5
     pnlres@lbLabelFontHeightF         = 0.015
    pnlres@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/) ; add strings to panel
  pnlres@amJust   = "TopLeft"
    gsn_panel(wks,(/plots/),(/2,2/),pnlres)

end do

end do 

end 
