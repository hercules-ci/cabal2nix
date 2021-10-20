{-# OPTIONS_GHC -fno-warn-orphans #-}

module Distribution.Nixpkgs.Haskell.OrphanInstances ( ) where

import Control.DeepSeq
import Data.Maybe
import Data.String
import qualified Data.Text as T
import Data.Yaml
import Distribution.Compiler
import Distribution.Nixpkgs.Meta
import Distribution.Package
import Distribution.Parsec
import Distribution.System
import Distribution.Types.PackageVersionConstraint
import Distribution.Pretty as Cabal
import qualified Data.Version as Base
import Distribution.Version
import Language.Nix.PrettyPrinting as Nix

instance NFData CompilerInfo
instance NFData AbiTag

instance IsString Version where
  fromString = text2isString "Version"

instance IsString VersionRange where
  fromString = text2isString "VersionRange"

instance IsString PackageIdentifier where
  fromString = text2isString "PackageIdentifier"

instance IsString PackageVersionConstraint where
  fromString = text2isString "PackageVersionConstraint"

instance IsString CompilerId where
  fromString = text2isString "CompilerId"

instance FromJSON NixpkgsPlatform where
  parseJSON (String s) =
    case nixpkgsPlatformFromString (T.unpack s) of
      Just p -> pure p
      Nothing -> fail ("parseJSON: " ++ show s ++ " is not a valid NixpkgsPlatform")
  parseJSON s =
    fail ("parseJSON: expected String for NixpkgsPlatform, but got " ++ show s)

instance FromJSON PackageName where
  parseJSON (String s) = return (fromString (T.unpack s))
  parseJSON s = fail ("parseJSON: " ++ show s ++ " is not a valid Haskell package name")

instance FromJSON PackageIdentifier where
  parseJSON (String s) = return (fromString (T.unpack s))
  parseJSON s = fail ("parseJSON: " ++ show s ++ " is not a valid Haskell package identifier")

instance FromJSON VersionRange where
  parseJSON (String s) = return (fromString (T.unpack s))
  parseJSON s = fail ("parseJSON: " ++ show s ++ " is not a valid Cabal VersionRange")

instance FromJSON PackageVersionConstraint where
  parseJSON (String s) = return (fromString (T.unpack s))
  parseJSON s = fail ("parseJSON: " ++ show s ++ " is not a valid Haskell PackageVersionConstraint")

instance FromJSON CompilerInfo where
  parseJSON (String s) = return (unknownCompilerInfo (fromString (T.unpack s)) NoAbiTag)
  parseJSON s = fail ("parseJSON: " ++ show s ++ " is not a valid Haskell compiler")

instance Nix.Pretty Version where
  pPrint = pretty

instance Nix.Pretty PackageName where
  pPrint = pretty

instance Nix.Pretty PackageIdentifier where
  pPrint = pretty

instance Nix.Pretty CompilerId where
  pPrint = pretty

instance Nix.Pretty Platform where
  pPrint = pretty

instance Nix.Pretty Base.Version where
  pPrint = text . Base.showVersion

-- parsing tools

text2isString :: Parsec a => String -> String -> a
text2isString t s = fromMaybe (error ("fromString: " ++ show s ++ " is not a valid " ++ t)) (simpleParsec s)
