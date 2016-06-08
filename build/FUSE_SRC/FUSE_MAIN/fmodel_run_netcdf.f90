SUBROUTINE FMODEL_RUN_NETCDF(OUTPUT_FLAG,SSTATS_FLAG)
! ---------------------------------------------------------------------------------------
! Creator:
! --------
! Martyn Clark, 2009
! ---------------------------------------------------------------------------------------
! Purpose:
! --------
! Run a single model with one parameter set (NetCDF output)
! ---------------------------------------------------------------------------------------
USE nrtype                                            ! variable types, etc.
! data modules
USE multiforce                                        ! model forcing data
USE multiparam                                        ! model parameters
USE multistate                                        ! model states
USE multiroute                                        ! routed runoff
USE multistats                                        ! summary statistics
! informational modules
USE par_insert_module                                 ! insert parameters into data structures                          
IMPLICIT NONE
! input
LOGICAL(LGT), INTENT(IN)               :: OUTPUT_FLAG ! .TRUE. if desire time series output
LOGICAL(LGT), INTENT(IN)               :: SSTATS_FLAG ! .TRUE. if desire time series output
! internal
INTEGER(I4B)                           :: ITIM        ! loop through time series
! ---------------------------------------------------------------------------------------
! increment parameter counter
PCOUNT = PCOUNT + 1
! write parameters to the NetCDF file
CALL PUT_PARAMS(PCOUNT,1)   ! PCOUNT = index for parameter set, 1 = just one model for numerix test
! initialize summary statistics
IF (SSTATS_FLAG) CALL INIT_STATS()
! initialize model states and model time step
CALL INIT_STATE(fracState0) ! fracState0 is shared in MODULE multistate
HSTATE%STEP = DELTIM        ! deltim is shared in module multiforce.
! loop through time
DO ITIM=1,NUMTIM            ! (NUMTIM is shared in MODULE multiforce)
 ! run model for one time step
 MFORCE = AFORCE(ITIM)      ! assign model forcing data
 CALL INITFLUXES()          ! set weighted sum of fluxes to zero
 CALL SUBSTEPPER()          ! run model for one time step using implicit solution with variable sub-steps
 CALL Q_OVERLAND()          ! overland flow routing
 ! save instantaneous and routed runoff
 AROUTE(ITIM)%Q_INSTNT = MROUTE%Q_INSTNT  ! save instantaneous runoff
 AROUTE(ITIM)%Q_ROUTED = MROUTE%Q_ROUTED  ! save routed runoff
 ! compute summary statistics
 IF (SSTATS_FLAG) CALL COMP_STATS()
 ! write output
 IF (OUTPUT_FLAG) THEN
  CALL PUT_OUTPUT(PCOUNT,1,ITIM)
  !WRITE(*,'(I10,1X,I4,1X,4(I2,1X),F9.3,1X,F20.1,1X,4(F11.3,1X))') ITIM, AFORCE(ITIM), AROUTE(ITIM)%Q_ROUTED
 ENDIF
 !if (itim.ge.355) pause
END DO  ! (itim)
! ---------------------------------------------------------------------------------------
END SUBROUTINE FMODEL_RUN_NETCDF
