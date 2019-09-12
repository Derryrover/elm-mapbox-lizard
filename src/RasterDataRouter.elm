module RasterDataRouter exposing(..)

import ApiRaster --exposing (Msg(..))
import RasterList

isEmitFromApi: ApiRaster.Msg -> Bool
isEmitFromApi msg =
  case msg of
    ApiRaster.Emit _ -> 
      True
    _ ->
      False

--getRasterListFromEmit: ApiRaster.Msg -> 