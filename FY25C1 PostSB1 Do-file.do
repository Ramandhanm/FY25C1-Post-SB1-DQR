***********Post SB1 DQR Template*************
***********Last updated: January 2025
	
	/*
	purpose of DQR: 
	-Check correct visit detail was selected and reasons for surveys not being completed
	-Create a time difference variable based on timestamps 
	-Investigate any duplicate surveys 
	-Check key variables for any data quality issues or missing data 
	-Create list of businesses that have not been surveyed yet 
	*/

	
*set up file paths
	cls
	clear 	
**import raw data 
	 
	import delimited "C:\Users\RamandhanMasudi\Desktop\FY25C1 Post SB1 DQR\FY25C1 Post SB 1.csv", varnames(1)
	des,short
    br
	rename (surveystarttime surveyendtime createddate createdbyfullname bmcyclename businessgroupid businessgroupname bizexpenses bizrevenue bizinventory bizcash bizinputs sbbusinesstype sbplannedbiztype sbplannedbiztypenotstarted sbplannedbiztypestarted whydeviatedfromsbplan biztypegroupcurrentlyoperating additionalbiztypesdetail ofbosdropped bosdropped groupsizeatsb sbgrantvalue sbgrantused businessparticipationstatus reasonunabletoviewrecords visitnumber recordskept recordsuptodate datacollectionmethod whysurveynotcompleted whysurveynotconducteddetail)(surveystarttime surveyendtime created_date mobileuser bm_cycle bg_id bg_name biz_expenses biz_revenue biz_inventory biz_cash biz_input sb_biz_type sb_planned_biz_type sbplannedbiztypenotstarted sbplannedbiztypestarted whydeviatedfromsbplan biztypegroupcurrentlyoperating additionalbiztypesdetail of_bos_dropped bos_dropped groupsizeatsb sb_value sb_invested businessparticipationstatus reason_unabletoview_records visit_number records_kept records_uptodate data_collection_method whysurvey_not_completed why_surveynotconducted_detail)
		
**check survey completion 
	ta mobileuser, mi
	/*
Created By: Full Name |      Freq.     Percent        Cum.
----------------------+-----------------------------------
        Amina Drateru |         40       10.05       10.05
Caroline Dawa Godfrey |         20        5.03       15.08
     Esther Angunduru |         48       12.06       27.14
       Hidaya Driciru |         50       12.56       39.70
        Justine Ndugu |         50       12.56       52.26
       Kenedy Munguci |         20        5.03       57.29
        Nadia Manzubo |         30        7.54       64.82
          Nenisa Gire |         20        5.03       69.85
       Phillimon Waka |         50       12.56       82.41
   Sadam Khamis Banya |         20        5.03       87.44
         Swaibu Akimu |         30        7.54       94.97
      William Aluonzi |         20        5.03      100.00
----------------------+-----------------------------------
                Total |        398      100.00

*/

	ta bm_cycle ,mi
	
/*
              BM Cycle Name |      Freq.     Percent        Cum.
----------------------------+-----------------------------------
       FY25C1 Annet Eyotaru |         30        7.54        7.54
       FY25C1 Charles Baker |         30        7.54       15.08
          FY25C1 David Bida |         30        7.54       22.61
        FY25C1 Fauzu Ajidra |         30        7.54       30.15
    FY25C1 Glorious Ayikoru |         30        7.54       37.69
         FY25C1 Hellen Muna |         30        7.54       45.23
        FY25C1 Isaac Candia |         30        7.54       52.76
FY25C1 Josline Peace Onyiru |         28        7.04       59.80
        FY25C1 Leila Zalika |         30        7.54       67.34
         FY25C1 Majid Taban |         30        7.54       74.87
      FY25C1 Modnes Akandru |         30        7.54       82.41
        FY25C1 Nassa Hindum |         40       10.05       92.46
   FY25C1 Santino Ojas Ware |         30        7.54      100.00
----------------------------+-----------------------------------
                      Total |        398      100.00
*/
	
ta visit_number, mi //Note: confirm that all surveys were Post SB 2, if not then follow up with enum and insert feedback
	/* 
	  Visit |
     Number |      Freq.     Percent        Cum.
------------+-----------------------------------
  Post SB 1 |        398      100.00      100.00
------------+-----------------------------------
      Total |        398      100.00
	*/
	
	ta whysurvey_not_completed	
	/*		
   
               Why Survey Not Completed |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
NOT APPLICABLE - THE SPOT CHECK IS BE.. |        398      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        398      100.00
	*/
	

**confirm no business groups were surveyed more than once 
	duplicates report bg_id
/*
   --------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |          396             0
        2 |            2             1
--------------------------------------
*/
duplicates tag bg_id, gen (Dups)
ta Dups, mi
li bm_cycle mobileuser surveystarttime bg_name bg_id  biz_cash biz_input biz_inventory if Dups>0 
/*
     +----------------------------------------------------------------------------+
     |             bm_cycle     mobileuser     surveystarttime   bg_name    bg_id |
     |----------------------------------------------------------------------------|
 13. | FY25C1 Annet Eyotaru   Swaibu Akimu   12/12/2024, 14:44   Icikiti   105538 |
 14. | FY25C1 Annet Eyotaru   Swaibu Akimu   12/12/2024, 15:15   Icikiti   105538 |
     +----------------------------------------------------------------------------+
*/
drop if bg_id==105538 & surveystarttime=="12/12/2024, 14:44" // mistakenly ended 

**check timestamps of surveys and confirm no dubious submissions 
	gen str time_sta = substr(surveystarttime, 1,16)	 
	gen double dt_start = clock(time_sta, "DMY hm")
	format dt_start %tc

	gen str time_end = substr(surveyendtime, 1,16)
	gen double dt_end = clock(time_end, "DMY hm")
	format dt_end %tc
	
	gen time_diff = minutes(dt_end - dt_start)
	ta time_diff mobileuser
	sum time_diff //Note: insert the average time of the survey
		
	bysort mobileuser : sum time_diff //Note: probe further into enum's averages, min, max
	//drop if time_diff < 5 //Note: drop any surveys that are completed in an unreasonable amount of time unless double checked with the enum 
	//The enumerators who spend less than 5 minutes made editing on the job after saving that made Taroworks capture only the edit minutes.
	
**investigate key variables
	*record keeping
	ta records_kept, mi
	ta records_uptodate, mi //Note: confirm that all who said yes to having business records, answered this question 
	ta reason_unabletoview_records, mi //Note: flag any unusual reasons and send to BMs
	 
	*group memberships
	ta bos_dropped, mi
	ta of_bos_dropped, mi //Note: confirm that all who said yes to members dropping, answered this question 
    li bm_cycle bg_id bg_name records_kept bos_dropped of_bos_dropped if bos_dropped=="Yes"
	/*
	 +-------------------------------------------------------------------------------------+
     |           bm_cycle    bg_id                bg_name   record~t   bos_dr~d   of_bos~d |
     |-------------------------------------------------------------------------------------|
242. | FY25C1 Majid Taban   105876   Iceta Business Group        Yes        Yes          1 |
     +-------------------------------------------------------------------------------------+
    */
    /// confirmed the members have dropped but follow-ups need to be done with BMs
   */
	*SB grant use
	ta sb_value, mi //Note: confirm these are all typical amounts given for sb
	ta sb_invested, mi 
	li mobileuser bm_cycle bg_id bg_name sb_invested if sb_invested==2500000 //  Confirmed the amount spend from enumerators
    /*
      +-----------------------------------------------------------------------------------------------+
     |            mobileuser                      bm_cycle    bg_id               bg_name   sb_inv~d |
     |-----------------------------------------------------------------------------------------------|
  5. |         Amina Drateru           FY25C1 Isaac Candia   105785                  Holy     130000 |
 48. | Caroline Dawa Godfrey      FY25C1 Santino Ojas Ware   105803       LONG JOURNEY BG     250000 |
 60. | Caroline Dawa Godfrey      FY25C1 Santino Ojas Ware   105814   GOD IS AVAILABLE BG     200000 |
 89. |      Esther Angunduru   FY25C1 Josline Peace Onyiru   105902       Poverty Fighter     300000 |
 99. |      Esther Angunduru   FY25C1 Josline Peace Onyiru   105901          Lover's star     300000 |
     |-----------------------------------------------------------------------------------------------|
117. |        Hidaya Driciru         FY25C1 Modnes Akandru   105618       Emmamuel  group     300000 |
137. |        Hidaya Driciru            FY25C1 Hellen Muna   105644                 Smart     156000 |
163. |         Justine Ndugu           FY25C1 Fauzu Ajidra   105587                   Joy     300000 |
181. |         Justine Ndugu           FY25C1 Fauzu Ajidra   105589            Eyete Ngun     300000 |
262. |           Nenisa Gire       FY25C1 Glorious Ayikoru   105760                 Unity      44000 |
     |-----------------------------------------------------------------------------------------------|
329. |    Sadam Khamis Banya       FY25C1 Glorious Ayikoru   106132                 Ulang     300000 |
331. |    Sadam Khamis Banya       FY25C1 Glorious Ayikoru   106131                Marang     300000 |
338. |    Sadam Khamis Banya       FY25C1 Glorious Ayikoru   106136                Baraka     200000 |
347. |    Sadam Khamis Banya       FY25C1 Glorious Ayikoru   106130               Karpont     300000 |
351. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105539                  Kazi     250000 |
     |-----------------------------------------------------------------------------------------------|
354. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105577                  Gift     300000 |
355. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105529                 Obizu     200000 |
356. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105918               Amatura     300000 |
363. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105538               Icikiti     250000 |
364. |          Swaibu Akimu          FY25C1 Annet Eyotaru   105919                Summer     300000 |
     +-----------------------------------------------------------------------------------------------+
    */
	replace sb_invested=440000 if sb_invested==44000  //Enumerator typing error
	replace sb_invested=250000 if sb_invested==2500000 // Enumerator typing error
	replace sb_invested=344000 if bg_id==105644        // Enumerator typing error
	
	gen proportionsbused = sb_invested / sb_value     //Note: create var for proportion of sb used to confirm no errors
	ta proportionsbused,mi	//Confirmed from the Enumerators about the less sb invested
	br bm_cycle mobileuser bg_id bg_name sb_invested proportionsbused if proportionsbused<1
	
	*business value    
	summ biz_input 
		ta biz_input //Note: look for any values like 99 or 999 which need to upcreated_dated to 0
	    br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_input<=50000
	    li bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_input>1000000
        replace biz_input=102200 if biz_input==1022000
		replace biz_input=455000 if biz_input==4550009
		replace biz_input=25000 if bg_id==105519
		replace biz_input=50000 if bg_id==105516
		

	summ biz_inventory 
		ta biz_inventory //Note: look for any values like 99 or 999 which need to upcreated_dated to 0
	    br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_inventory<=100000
        br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_inventory==0
		br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_inventory>=1000000
        replace biz_inventory=117900 if bg_id==105898
		replace biz_inventory=120000 if bg_id==105615
		replace biz_inventory=187000 if bg_id==106084
		replace biz_inventory=40000 if bg_id==105755
		// Groups with zero inventory are mostly crops businesses with crops yet to be harvested
    summ biz_cash
		ta biz_cash //Note: look for any values like 99 or 999 which need to upcreated_dated to 0
	  	br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_cash<=100000
        br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name sb_invested proportionsbused if biz_cash>=500000
        replace biz_cash=60000 if bg_id==105705
		replace biz_cash=53000 if bg_id==105898
        replace biz_cash=20000 if bg_id==105646
		replace biz_cash=100000 if biz_cash==1000000     // Enumerator typing errors
		replace biz_cash=110000 if biz_cash==1100000
		replace biz_cash=166700 if biz_cash==1667700
		replace biz_cash=228000 if biz_cash==2280000
		// biz_input seem to match with the business types & the business inputs & inventories
		
	replace bizvalue = biz_input + biz_inventory + biz_cash
	summ bizvalue, detail
		ta bizvalue	//Note: flag any outliters that require follow up
	    br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name bizvalue sb_invested proportionsbused if bizvalue<=500000
	    br bm_cycle mobileuser biz_input sb_biz_type biz_inventory biz_cash records_uptodate bg_id bg_name bizvalue sb_invested proportionsbused if bizvalue>=1000000
		// bizvalue matches with the business types 
	

	save "C:\Users\RamandhanMasudi\Desktop\FY25C1 Post SB1 DQR\FY25C1 Post SB 1 Cleaned.dta", replace //Note save clean dta 


