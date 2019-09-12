module RasterDataRouter exposing(isEmitFromApi, getRasterListFromEmit)

import ApiRaster
import RasterList

isEmitFromApi: ApiRaster.Msg -> Bool
isEmitFromApi msg =
  case msg of
    ApiRaster.Emit _ -> 
      True
    _ ->
      False

getRasterListFromEmit: ApiRaster.Msg -> RasterList.Msg
getRasterListFromEmit msg = 
  case msg of
    ApiRaster.Emit data ->
      RasterList.ReceivedRasters data.results
    _ ->
      RasterList.ReceivedRasters []