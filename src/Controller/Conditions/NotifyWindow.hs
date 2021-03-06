-- | Shows a pseudo-overlay window when the user must be notified and this kind
-- of notification is enabled
module Controller.Conditions.NotifyWindow where

import Control.Arrow
import Control.Monad
import Graphics.UI.Gtk

import CombinedEnvironment
import Model.Model (Status(..))
import Hails.MVC.Model.ProtectedModel.Reactive

-- | Notifies/stops notifying when the system is started, or when notification,
-- status or overlay are changed.
installHandlers :: CEnv -> IO()
installHandlers cenv = void $ do
  let (vw, pm) = (view &&& model) cenv
  onEvent pm Initialised                       $ condition cenv
  onEvent pm NotificationEnabledChanged        $ condition cenv
  onEvent pm NotificationOverlayEnabledChanged $ condition cenv
  onEvent pm StatusChanged                     $ condition cenv

  -- FIXME: This should be on the view only
  win <- notificationWindow $ mainWindowBuilder vw
  widgetModifyBg win StateNormal $ Color 65256 32256 32256

-- | Resets the visibility of the notification window
condition :: CEnv -> IO()
condition cenv = onViewAsync $ do
  let (vw, pm) = (view &&& model) cenv
  status         <- getStatus pm
  notifyEnabled  <- getter notificationEnabledField pm
  overlayEnabled <- getter notificationOverlayEnabledField pm
  win            <- notificationWindow $ mainWindowBuilder vw
  
  if status == StatusNotifying && notifyEnabled && overlayEnabled
   then widgetShowAll win
   else widgetHideAll win
