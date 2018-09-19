#!/bin/bash
# Patch apllying tool template
# v0.1.2
# (c) Copyright 2013. Magento Inc.
#
# DO NOT CHANGE ANY LINE IN THIS FILE.

# 1. Check required system tools
_check_installed_tools() {
    local missed=""

    until [ -z "$1" ]; do
        type -t $1 >/dev/null 2>/dev/null
        if (( $? != 0 )); then
            missed="$missed $1"
        fi
        shift
    done

    echo $missed
}

REQUIRED_UTILS='sed patch'
MISSED_REQUIRED_TOOLS=`_check_installed_tools $REQUIRED_UTILS`
if (( `echo $MISSED_REQUIRED_TOOLS | wc -w` > 0 ));
then
    echo -e "Error! Some required system tools, that are utilized in this sh script, are not installed:\nTool(s) \"$MISSED_REQUIRED_TOOLS\" is(are) missed, please install it(them)."
    exit 1
fi

# 2. Determine bin path for system tools
CAT_BIN=`which cat`
PATCH_BIN=`which patch`
SED_BIN=`which sed`
PWD_BIN=`which pwd`
BASENAME_BIN=`which basename`

BASE_NAME=`$BASENAME_BIN "$0"`

# 3. Help menu
if [ "$1" = "-?" -o "$1" = "-h" -o "$1" = "--help" ]
then
    $CAT_BIN << EOFH
Usage: sh $BASE_NAME [--help] [-R|--revert] [--list]
Apply embedded patch.

-R, --revert    Revert previously applied embedded patch
--list          Show list of applied patches
--help          Show this help message
EOFH
    exit 0
fi

# 4. Get "revert" flag and "list applied patches" flag
REVERT_FLAG=
SHOW_APPLIED_LIST=0
if [ "$1" = "-R" -o "$1" = "--revert" ]
then
    REVERT_FLAG=-R
fi
if [ "$1" = "--list" ]
then
    SHOW_APPLIED_LIST=1
fi

# 5. File pathes
CURRENT_DIR=`$PWD_BIN`/
APP_ETC_DIR=`echo "$CURRENT_DIR""app/etc/"`
APPLIED_PATCHES_LIST_FILE=`echo "$APP_ETC_DIR""applied.patches.list"`

# 6. Show applied patches list if requested
if [ "$SHOW_APPLIED_LIST" -eq 1 ] ; then
    echo -e "Applied/reverted patches list:"
    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -r "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be readable so applied patches list can be shown."
            exit 1
        else
            $SED_BIN -n "/SUP-\|SUPEE-/p" $APPLIED_PATCHES_LIST_FILE
        fi
    else
        echo "<empty>"
    fi
    exit 0
fi

# 7. Check applied patches track file and its directory
_check_files() {
    if [ ! -e "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must exist for proper tool work."
        exit 1
    fi

    if [ ! -w "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must be writeable for proper tool work."
        exit 1
    fi

    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -w "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be writeable for proper tool work."
            exit 1
        fi
    fi
}

_check_files

# 8. Apply/revert patch
# Note: there is no need to check files permissions for files to be patched.
# "patch" tool will not modify any file if there is not enough permissions for all files to be modified.
# Get start points for additional information and patch data
SKIP_LINES=$((`$SED_BIN -n "/^__PATCHFILE_FOLLOWS__$/=" "$CURRENT_DIR""$BASE_NAME"` + 1))
ADDITIONAL_INFO_LINE=$(($SKIP_LINES - 3))p

_apply_revert_patch() {
    DRY_RUN_FLAG=
    if [ "$1" = "dry-run" ]
    then
        DRY_RUN_FLAG=" --dry-run"
        echo "Checking if patch can be applied/reverted successfully..."
    fi
    PATCH_APPLY_REVERT_RESULT=`$SED_BIN -e '1,/^__PATCHFILE_FOLLOWS__$/d' "$CURRENT_DIR""$BASE_NAME" | $PATCH_BIN $DRY_RUN_FLAG $REVERT_FLAG -p0`
    PATCH_APPLY_REVERT_STATUS=$?
    if [ $PATCH_APPLY_REVERT_STATUS -eq 1 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully.\n\n$PATCH_APPLY_REVERT_RESULT"
        exit 1
    fi
    if [ $PATCH_APPLY_REVERT_STATUS -eq 2 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully."
        exit 2
    fi
}

REVERTED_PATCH_MARK=
if [ -n "$REVERT_FLAG" ]
then
    REVERTED_PATCH_MARK=" | REVERTED"
fi

_apply_revert_patch dry-run
_apply_revert_patch

# 9. Track patch applying result
echo "Patch was applied/reverted successfully."
ADDITIONAL_INFO=`$SED_BIN -n ""$ADDITIONAL_INFO_LINE"" "$CURRENT_DIR""$BASE_NAME"`
APPLIED_REVERTED_ON_DATE=`date -u +"%F %T UTC"`
APPLIED_REVERTED_PATCH_INFO=`echo -n "$APPLIED_REVERTED_ON_DATE"" | ""$ADDITIONAL_INFO""$REVERTED_PATCH_MARK"`
echo -e "$APPLIED_REVERTED_PATCH_INFO\n$PATCH_APPLY_REVERT_RESULT\n\n" >> "$APPLIED_PATCHES_LIST_FILE"

exit 0


SUPEE-10888_CE_v1.6.0.0 | CE_1.6.0.0 | v1 | d797968a45d46df8f3d5399af61a277847f30062 | Fri Sep 7 22:33:34 2018 +0300 | ce-1.6.0.0-dev

__PATCHFILE_FOLLOWS__
diff --git app/code/core/Mage/Admin/Model/User.php app/code/core/Mage/Admin/Model/User.php
index 13f29947b0c..617fce9f925 100644
--- app/code/core/Mage/Admin/Model/User.php
+++ app/code/core/Mage/Admin/Model/User.php
@@ -67,6 +67,11 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
 
     protected $_eventPrefix = 'admin_user';
 
+    /** Configuration paths for notifications */
+    const XML_PATH_ADDITIONAL_EMAILS             = 'general/additional_notification_emails/admin_user_create';
+    const XML_PATH_NOTIFICATION_EMAILS_TEMPLATE  = 'admin/emails/admin_notification_email_template';
+    /**#@-*/
+
     /**
      * @var Mage_Admin_Model_Roles
      */
@@ -469,4 +474,52 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
         return (array)$errors;
     }
 
+    /**
+     * Send notification to general Contact and additional emails when new admin user created.
+     * You can declare additional emails in Mage_Core general/additional_notification_emails/admin_user_create node.
+     *
+     * @param $user
+     * @return $this
+     */
+    public function sendAdminNotification($user)
+    {
+        // define general contact Name and Email
+        $generalContactName = Mage::getStoreConfig('trans_email/ident_general/name');
+        $generalContactEmail = Mage::getStoreConfig('trans_email/ident_general/email');
+
+        // collect general and additional emails
+        $emails = $this->getUserCreateAdditionalEmail();
+        $emails[] = $generalContactEmail;
+
+        /** @var $mailer Mage_Core_Model_Email_Template_Mailer */
+        $mailer    = Mage::getModel('core/email_template_mailer');
+        $emailInfo = Mage::getModel('core/email_info');
+        $emailInfo->addTo(array_filter($emails), $generalContactName);
+        $mailer->addEmailInfo($emailInfo);
+
+        // Set all required params and send emails
+        $mailer->setSender(array(
+            'name'  => $generalContactName,
+            'email' => $generalContactEmail,
+        ));
+        $mailer->setStoreId(0);
+        $mailer->setTemplateId(Mage::getStoreConfig(self::XML_PATH_NOTIFICATION_EMAILS_TEMPLATE));
+        $mailer->setTemplateParams(array(
+            'user' => $user,
+        ));
+        $mailer->send();
+
+        return $this;
+    }
+
+    /**
+     * Get additional emails for notification from config.
+     *
+     * @return array
+     */
+    public function getUserCreateAdditionalEmail()
+    {
+        $emails = str_replace(' ', '', Mage::getStoreConfig(self::XML_PATH_ADDITIONAL_EMAILS));
+        return explode(',', $emails);
+    }
 }
diff --git app/code/core/Mage/Admin/etc/config.xml app/code/core/Mage/Admin/etc/config.xml
index 2759d35115c..c9ce82425a4 100644
--- app/code/core/Mage/Admin/etc/config.xml
+++ app/code/core/Mage/Admin/etc/config.xml
@@ -84,6 +84,7 @@
         <admin>
             <emails>
                 <forgot_email_template>admin_emails_forgot_email_template</forgot_email_template>
+                <admin_notification_email_template>admin_emails_admin_notification_email_template</admin_notification_email_template>
                 <forgot_email_identity>general</forgot_email_identity>
             </emails>
         </admin>
diff --git app/code/core/Mage/Adminhtml/Block/Catalog/Product/Edit/Tab/Super/Config.php app/code/core/Mage/Adminhtml/Block/Catalog/Product/Edit/Tab/Super/Config.php
index 31a6a229ee8..eadb8dee888 100644
--- app/code/core/Mage/Adminhtml/Block/Catalog/Product/Edit/Tab/Super/Config.php
+++ app/code/core/Mage/Adminhtml/Block/Catalog/Product/Edit/Tab/Super/Config.php
@@ -133,6 +133,7 @@ class Mage_Adminhtml_Block_Catalog_Product_Edit_Tab_Super_Config extends Mage_Ad
         } else {
             // Hide price if needed
             foreach ($attributes as &$attribute) {
+                $attribute['label'] = $this->escapeHtml($attribute['label']);
                 if (isset($attribute['values']) && is_array($attribute['values'])) {
                     foreach ($attribute['values'] as &$attributeValue) {
                         if (!$this->getCanReadPrice()) {
diff --git app/code/core/Mage/Adminhtml/Block/Widget/Grid/Massaction/Abstract.php app/code/core/Mage/Adminhtml/Block/Widget/Grid/Massaction/Abstract.php
index 7b794e8fb2d..7bb6190a42a 100644
--- app/code/core/Mage/Adminhtml/Block/Widget/Grid/Massaction/Abstract.php
+++ app/code/core/Mage/Adminhtml/Block/Widget/Grid/Massaction/Abstract.php
@@ -185,7 +185,7 @@ abstract class Mage_Adminhtml_Block_Widget_Grid_Massaction_Abstract extends Mage
     public function getSelectedJson()
     {
         if($selected = $this->getRequest()->getParam($this->getFormFieldNameInternal())) {
-            $selected = explode(',', $selected);
+            $selected = explode(',', $this->quoteEscape($selected));
             return join(',', $selected);
 //            return Mage::helper('core')->jsonEncode($selected);
         } else {
@@ -202,7 +202,7 @@ abstract class Mage_Adminhtml_Block_Widget_Grid_Massaction_Abstract extends Mage
     public function getSelected()
     {
         if($selected = $this->getRequest()->getParam($this->getFormFieldNameInternal())) {
-            $selected = explode(',', $selected);
+            $selected = explode(',', $this->quoteEscape($selected));
             return $selected;
         } else {
             return array();
diff --git app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
index 7ff0a7d9df5..e06af3f6af0 100644
--- app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
+++ app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
@@ -38,6 +38,7 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
 {
     const XML_INVALID                             = 'invalidXml';
     const INVALID_TEMPLATE_PATH                   = 'invalidTemplatePath';
+    const INVALID_BLOCK_NAME                      = 'invalidBlockName';
     const PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR = 'protectedAttrHelperInActionVar';
 
     /**
@@ -56,7 +57,18 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
         '*//template',
         '*//@template',
         '//*[@method=\'setTemplate\']',
-        '//*[@method=\'setDataUsingMethod\']//*[text() = \'template\']/../*'
+        '//*[@method=\'setDataUsingMethod\']//*[contains(translate(text(),
+        \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\', \'abcdefghijklmnopqrstuvwxyz\'), \'template\')]/../*',
+    );
+
+    /**
+     * Disallowed template name
+     *
+     * @var array
+     */
+    protected $_disallowedBlock = array(
+        'Mage_Install_Block_End',
+        'Mage_Rss_Block_Order_New',
     );
 
     /**
@@ -91,6 +103,7 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
                 self::INVALID_TEMPLATE_PATH => Mage::helper('adminhtml')->__(
                     'Invalid template path used in layout update.'
                 ),
+                self::INVALID_BLOCK_NAME => Mage::helper('adminhtml')->__('Disallowed block name for frontend.'),
             );
         }
         return $this;
@@ -125,6 +138,10 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
                 Mage::helper('adminhtml')->__('XML object is not instance of "Varien_Simplexml_Element".'));
         }
 
+        if ($value->xpath($this->_getXpathBlockValidationExpression())) {
+            $this->_error(self::INVALID_BLOCK_NAME);
+            return false;
+        }
         // if layout update declare custom templates then validate their paths
         if ($templatePaths = $value->xpath($this->_getXpathValidationExpression())) {
             try {
@@ -154,6 +171,20 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
         return implode(" | ", $this->_disallowedXPathExpressions);
     }
 
+    /**
+     * Returns xPath for validate incorrect block name
+     *
+     * @return string xPath for validate incorrect block name
+     */
+    protected function _getXpathBlockValidationExpression() {
+        $xpath = "";
+        if (count($this->_disallowedBlock)) {
+            $xpath = "//block[@type='";
+            $xpath .= implode("'] | //block[@type='", $this->_disallowedBlock) . "']";
+        }
+        return $xpath;
+    }
+
     /**
      * Validate template path for preventing access to the directory above
      * If template path value has "../" @throws Exception
@@ -162,7 +193,11 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      */
     protected function _validateTemplatePath(array $templatePaths)
     {
+        /**@var $path Varien_Simplexml_Element */
         foreach ($templatePaths as $path) {
+            if ($path->hasChildren()) {
+                $path = stripcslashes(trim((string) $path->children(), '"'));
+            }
             if (strpos($path, '..' . DS) !== false) {
                 throw new Exception();
             }
diff --git app/code/core/Mage/Adminhtml/controllers/Catalog/ProductController.php app/code/core/Mage/Adminhtml/controllers/Catalog/ProductController.php
index 99a0c5b5d71..61641e264c3 100644
--- app/code/core/Mage/Adminhtml/controllers/Catalog/ProductController.php
+++ app/code/core/Mage/Adminhtml/controllers/Catalog/ProductController.php
@@ -991,6 +991,16 @@ class Mage_Adminhtml_Catalog_ProductController extends Mage_Adminhtml_Controller
         }
 
         $product->addData($this->getRequest()->getParam('simple_product', array()));
+
+        $productSku = $product->getSku();
+        if ($productSku && $productSku != Mage::helper('core')->stripTags($productSku)) {
+            $result['error'] = array(
+                'message' => $this->__('HTML tags are not allowed in SKU attribute.')
+            );
+            $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));
+            return;
+        }
+
         $product->setWebsiteIds($configurableProduct->getWebsiteIds());
 
         $autogenerateOptions = array();
diff --git app/code/core/Mage/Adminhtml/controllers/Permissions/UserController.php app/code/core/Mage/Adminhtml/controllers/Permissions/UserController.php
index fa201c28607..79665cc138c 100644
--- app/code/core/Mage/Adminhtml/controllers/Permissions/UserController.php
+++ app/code/core/Mage/Adminhtml/controllers/Permissions/UserController.php
@@ -96,6 +96,8 @@ class Mage_Adminhtml_Permissions_UserController extends Mage_Adminhtml_Controlle
 
             $id = $this->getRequest()->getParam('user_id');
             $model = Mage::getModel('admin/user')->load($id);
+            // @var $isNew flag for detecting new admin user creation.
+            $isNew = !$model->getId() ? true : false;
             if (!$model->getId() && $id) {
                 Mage::getSingleton('adminhtml/session')->addError($this->__('This user no longer exists.'));
                 $this->_redirect('*/*/');
@@ -125,6 +127,10 @@ class Mage_Adminhtml_Permissions_UserController extends Mage_Adminhtml_Controlle
 
             try {
                 $model->save();
+                // Send notification to General and additional contacts (if declared) that a new admin user was created.
+                if (Mage::getStoreConfigFlag('admin/security/crate_admin_user_notification') && $isNew) {
+                    Mage::getModel('admin/user')->sendAdminNotification($model);
+                }
                 if ( $uRoles = $this->getRequest()->getParam('roles', false) ) {
                     /*parse_str($uRoles, $uRoles);
                     $uRoles = array_keys($uRoles);*/
diff --git app/code/core/Mage/Adminhtml/etc/config.xml app/code/core/Mage/Adminhtml/etc/config.xml
index 7e4806dbfa4..6295024320e 100644
--- app/code/core/Mage/Adminhtml/etc/config.xml
+++ app/code/core/Mage/Adminhtml/etc/config.xml
@@ -54,6 +54,11 @@
                     <file>admin_password_new.html</file>
                     <type>html</type>
                 </admin_emails_forgot_email_template>
+                <admin_emails_admin_notification_email_template>
+                    <label>New Admin User Create Notification</label>
+                    <file>admin_new_user_notification.html</file>
+                    <type>html</type>
+                </admin_emails_admin_notification_email_template>
             </email>
         </template>
         <events>
diff --git app/code/core/Mage/Checkout/Model/Api/Resource/Customer.php app/code/core/Mage/Checkout/Model/Api/Resource/Customer.php
index 2074ecbc4a7..8310aa92789 100644
--- app/code/core/Mage/Checkout/Model/Api/Resource/Customer.php
+++ app/code/core/Mage/Checkout/Model/Api/Resource/Customer.php
@@ -153,7 +153,7 @@ class Mage_Checkout_Model_Api_Resource_Customer extends Mage_Checkout_Model_Api_
         $customer->setPasswordCreatedAt(time());
         $quote->setCustomer($customer)
             ->setCustomerId(true);
-
+        $quote->setPasswordHash('');
         return $this;
     }
 
diff --git app/code/core/Mage/Checkout/Model/Type/Onepage.php app/code/core/Mage/Checkout/Model/Type/Onepage.php
index cbc9428c69c..6f06a80cbba 100644
--- app/code/core/Mage/Checkout/Model/Type/Onepage.php
+++ app/code/core/Mage/Checkout/Model/Type/Onepage.php
@@ -683,6 +683,7 @@ class Mage_Checkout_Model_Type_Onepage
         $customer->setPasswordCreatedAt($passwordCreatedTime);
         $quote->setCustomer($customer)
             ->setCustomerId(true);
+        $quote->setPasswordHash('');
     }
 
     /**
diff --git app/code/core/Mage/Cms/Model/Wysiwyg/Images/Storage.php app/code/core/Mage/Cms/Model/Wysiwyg/Images/Storage.php
index a0a7fedb4cf..8554473d51b 100644
--- app/code/core/Mage/Cms/Model/Wysiwyg/Images/Storage.php
+++ app/code/core/Mage/Cms/Model/Wysiwyg/Images/Storage.php
@@ -282,11 +282,13 @@ class Mage_Cms_Model_Wysiwyg_Images_Storage extends Varien_Object
         }
         $uploader->setAllowRenameFiles(true);
         $uploader->setFilesDispersion(false);
-        $uploader->addValidateCallback(
-            Mage_Core_Model_File_Validator_Image::NAME,
-            Mage::getModel('core/file_validator_image'),
-            'validate'
-        );
+        if ($type == 'image') {
+            $uploader->addValidateCallback(
+                Mage_Core_Model_File_Validator_Image::NAME,
+                Mage::getModel('core/file_validator_image'),
+                'validate'
+            );
+        }
         $result = $uploader->save($targetPath);
 
         if (!$result) {
@@ -294,8 +296,9 @@ class Mage_Cms_Model_Wysiwyg_Images_Storage extends Varien_Object
         }
 
         // create thumbnail
-        $this->resizeFile($targetPath . DS . $uploader->getUploadedFileName(), true);
-
+        if ($type == 'image') {
+            $this->resizeFile($targetPath . DS . $uploader->getUploadedFileName(), true);
+        }
         $result['cookie'] = array(
             'name'     => session_name(),
             'value'    => $this->getSession()->getSessionId(),
diff --git app/code/core/Mage/Core/etc/config.xml app/code/core/Mage/Core/etc/config.xml
index bb53066d897..258eb5afd7c 100644
--- app/code/core/Mage/Core/etc/config.xml
+++ app/code/core/Mage/Core/etc/config.xml
@@ -409,6 +409,11 @@
             <reprocess_images>
                 <active>1</active>
             </reprocess_images>
+            <!-- Additional email for notifications -->
+            <additional_notification_emails>
+                <!-- On creating a new admin user. You can specify several emails separated by commas. -->
+                <admin_user_create></admin_user_create>
+            </additional_notification_emails>
         </general>
     </default>
     <stores>
diff --git app/code/core/Mage/Core/etc/system.xml app/code/core/Mage/Core/etc/system.xml
index deb1426dde7..c71efb45f4d 100644
--- app/code/core/Mage/Core/etc/system.xml
+++ app/code/core/Mage/Core/etc/system.xml
@@ -1053,6 +1053,16 @@
                             <show_in_website>0</show_in_website>
                             <show_in_store>0</show_in_store>
                         </extensions_compatibility_mode>
+                        <crate_admin_user_notification translate="label comment">
+                            <label>New Admin User Create Notification</label>
+                            <comment>This setting enable notification when new admin user created.</comment>
+                            <frontend_type>select</frontend_type>
+                            <sort_order>10</sort_order>
+                            <source_model>adminhtml/system_config_source_enabledisable</source_model>
+                            <show_in_default>1</show_in_default>
+                            <show_in_website>0</show_in_website>
+                            <show_in_store>0</show_in_store>
+                        </crate_admin_user_notification>
                     </fields>
                 </security>
                 <dashboard translate="label">
diff --git app/code/core/Mage/Customer/Helper/Data.php app/code/core/Mage/Customer/Helper/Data.php
index 23ed8b35651..7035fdc96e6 100644
--- app/code/core/Mage/Customer/Helper/Data.php
+++ app/code/core/Mage/Customer/Helper/Data.php
@@ -317,6 +317,17 @@ class Mage_Customer_Helper_Data extends Mage_Core_Helper_Abstract
         return is_null($passwordCreatedAt) ? $customer->getCreatedAtTimestamp() : $passwordCreatedAt;
     }
 
+    /**
+     * Generate unique token based on customer Id for reset password confirmation link
+     *
+     * @param $customerId
+     * @return string
+     */
+    public function generateResetPasswordLinkCustomerId($customerId)
+    {
+        return md5(uniqid($customerId . microtime() . mt_rand(), true));
+    }
+
     /**
      * Unserialize and clear name prefix or suffix options
      *
diff --git app/code/core/Mage/Customer/Model/Customer.php app/code/core/Mage/Customer/Model/Customer.php
index c9d10c42ea1..7073a23872d 100644
--- app/code/core/Mage/Customer/Model/Customer.php
+++ app/code/core/Mage/Customer/Model/Customer.php
@@ -49,6 +49,7 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
     const EXCEPTION_EMAIL_NOT_CONFIRMED       = 1;
     const EXCEPTION_INVALID_EMAIL_OR_PASSWORD = 2;
     const EXCEPTION_EMAIL_EXISTS              = 3;
+    const EXCEPTION_INVALID_RESET_PASSWORD_LINK_CUSTOMER_ID = 5;
 
     const SUBSCRIBED_YES = 'yes';
     const SUBSCRIBED_NO  = 'no';
@@ -1181,6 +1182,28 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
         return $entityTypeId;
     }
 
+    /**
+     * Change reset password link customer Id
+     *
+     * Stores new reset password link customer Id
+     *
+     * @param string $newResetPasswordLinkCustomerId
+     * @return Mage_Customer_Model_Customer
+     * @throws Mage_Core_Exception
+     */
+    public function changeResetPasswordLinkCustomerId($newResetPasswordLinkCustomerId)
+    {
+        if (!is_string($newResetPasswordLinkCustomerId) || empty($newResetPasswordLinkCustomerId)) {
+            throw Mage::exception(
+                'Mage_Core',
+                Mage::helper('customer')->__('Invalid password reset customer Id.'),
+                self::EXCEPTION_INVALID_RESET_PASSWORD_LINK_CUSTOMER_ID
+            );
+        }
+        $this->_getResource()->changeResetPasswordLinkCustomerId($this, $newResetPasswordLinkCustomerId);
+        return $this;
+    }
+
     /**
      * Get either first store ID from a set website or the provided as default
      *
diff --git app/code/core/Mage/Customer/Model/Resource/Customer.php app/code/core/Mage/Customer/Model/Resource/Customer.php
index 17aa1998d0d..b9a969fffed 100755
--- app/code/core/Mage/Customer/Model/Resource/Customer.php
+++ app/code/core/Mage/Customer/Model/Resource/Customer.php
@@ -313,4 +313,25 @@ class Mage_Customer_Model_Resource_Customer extends Mage_Eav_Model_Entity_Abstra
         }
         return $this;
     }
+
+    /**
+     * Change reset password link customer Id
+     *
+     * Stores new reset password link customer Id
+     *
+     * @param Mage_Customer_Model_Customer $customer
+     * @param string $newResetPasswordLinkCustomerId
+     * @return Mage_Customer_Model_Resource_Customer
+     * @throws Exception
+     */
+    public function changeResetPasswordLinkCustomerId(
+        Mage_Customer_Model_Customer $customer,
+        $newResetPasswordLinkCustomerId
+    ) {
+        if (is_string($newResetPasswordLinkCustomerId) && !empty($newResetPasswordLinkCustomerId)) {
+            $customer->setRpCustomerId($newResetPasswordLinkCustomerId);
+            $this->saveAttribute($customer, 'rp_customer_id');
+        }
+        return $this;
+    }
 }
diff --git app/code/core/Mage/Customer/controllers/AccountController.php app/code/core/Mage/Customer/controllers/AccountController.php
index 71bfa58e99f..a02b222ab71 100644
--- app/code/core/Mage/Customer/controllers/AccountController.php
+++ app/code/core/Mage/Customer/controllers/AccountController.php
@@ -695,8 +695,12 @@ class Mage_Customer_AccountController extends Mage_Core_Controller_Front_Action
                 ->setWebsiteId(Mage::app()->getStore()->getWebsiteId())
                 ->loadByEmail($email);
 
-            if ($customer->getId()) {
+            $customerId = $customer->getId();
+            if ($customerId) {
                 try {
+                    $newResetPasswordLinkCustomerId = $this->_getHelper('customer')
+                        ->generateResetPasswordLinkCustomerId($customerId);
+                    $customer->changeResetPasswordLinkCustomerId($newResetPasswordLinkCustomerId);
                     $newPassword = $customer->generatePassword();
                     $customer->changePassword($newPassword, false);
                     $customer->sendPasswordReminderEmail();
@@ -825,6 +829,7 @@ class Mage_Customer_AccountController extends Mage_Core_Controller_Front_Action
             try {
                 $customer->setConfirmation(null);
                 $customer->setPasswordCreatedAt(time());
+                $customer->setRpCustomerId(null);
                 $customer->save();
                 $this->_getSession()->setCustomer($customer)
                     ->addSuccess($this->__('The account information has been saved.'));
@@ -843,6 +848,25 @@ class Mage_Customer_AccountController extends Mage_Core_Controller_Front_Action
         $this->_redirect('*/*/edit');
     }
 
+    /**
+     * @return mixed
+     */
+    protected function getCustomerId()
+    {
+        $customerId = $this->getRequest()->getQuery("id");
+        if (strlen($customerId) > 12) {
+            $customerCollection = $this->_getModel('customer/customer')
+                ->getCollection()
+                ->addAttributeToSelect(array('rp_customer_id'))
+                ->addFieldToFilter('rp_customer_id', $customerId);
+            $customerId = count($customerCollection) === 1
+                ? $customerId = $customerCollection->getFirstItem()->getId()
+                : false;
+        }
+
+        return $customerId;
+    }
+
     /**
      * Filtering posted data. Converting localized data if needed
      *
diff --git app/code/core/Mage/Customer/etc/config.xml app/code/core/Mage/Customer/etc/config.xml
index 00499266f86..0f7b72a5150 100644
--- app/code/core/Mage/Customer/etc/config.xml
+++ app/code/core/Mage/Customer/etc/config.xml
@@ -28,7 +28,7 @@
 <config>
     <modules>
         <Mage_Customer>
-            <version>1.6.0.0.1.2</version>
+            <version>1.6.0.0.1.3</version>
         </Mage_Customer>
     </modules>
     <admin>
diff --git app/code/core/Mage/Customer/sql/customer_setup/upgrade-1.6.0.0.1.2-1.6.0.0.1.3.php app/code/core/Mage/Customer/sql/customer_setup/upgrade-1.6.0.0.1.2-1.6.0.0.1.3.php
new file mode 100644
index 00000000000..867227ea4bb
--- /dev/null
+++ app/code/core/Mage/Customer/sql/customer_setup/upgrade-1.6.0.0.1.2-1.6.0.0.1.3.php
@@ -0,0 +1,39 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Customer
+ * @copyright  Copyright (c) 2006-2018 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/* @var $installer Mage_Customer_Model_Entity_Setup */
+$installer = $this;
+$installer->startSetup();
+
+// Add reset password link customer Id attribute
+$installer->addAttribute('customer', 'rp_customer_id', array(
+    'type'     => 'varchar',
+    'input'    => 'hidden',
+    'visible'  => false,
+    'required' => false
+));
+
+$installer->endSetup();
diff --git app/code/core/Mage/Downloadable/Block/Adminhtml/Catalog/Product/Edit/Tab/Downloadable/Links.php app/code/core/Mage/Downloadable/Block/Adminhtml/Catalog/Product/Edit/Tab/Downloadable/Links.php
index 0e0d6770f02..4a96011c89c 100644
--- app/code/core/Mage/Downloadable/Block/Adminhtml/Catalog/Product/Edit/Tab/Downloadable/Links.php
+++ app/code/core/Mage/Downloadable/Block/Adminhtml/Catalog/Product/Edit/Tab/Downloadable/Links.php
@@ -159,7 +159,7 @@ class Mage_Downloadable_Block_Adminhtml_Catalog_Product_Edit_Tab_Downloadable_Li
         foreach ($links as $item) {
             $tmpLinkItem = array(
                 'link_id' => $item->getId(),
-                'title' => $item->getTitle(),
+                'title' => $this->escapeHtml($item->getTitle()),
                 'price' => $this->getCanReadPrice() ? $this->getPriceValue($item->getPrice()) : '',
                 'number_of_downloads' => $item->getNumberOfDownloads(),
                 'is_shareable' => $item->getIsShareable(),
diff --git app/code/core/Mage/Paypal/Model/Express/Checkout.php app/code/core/Mage/Paypal/Model/Express/Checkout.php
index cfc426d787a..593ec49e3c4 100644
--- app/code/core/Mage/Paypal/Model/Express/Checkout.php
+++ app/code/core/Mage/Paypal/Model/Express/Checkout.php
@@ -87,6 +87,11 @@ class Mage_Paypal_Model_Express_Checkout
     protected $_pendingPaymentMessage = '';
     protected $_checkoutRedirectUrl = '';
 
+    /**
+     * @var Mage_Customer_Model_Session
+     */
+    protected $_customerSession;
+
     /**
      * Redirect urls supposed to be set to support giropay
      *
@@ -145,6 +150,7 @@ class Mage_Paypal_Model_Express_Checkout
         } else {
             throw new Exception('Config instance is required.');
         }
+        $this->_customerSession = Mage::getSingleton('customer/session');
     }
 
     /**
@@ -340,6 +346,10 @@ class Mage_Paypal_Model_Express_Checkout
 
     /**
      * Update quote when returned from PayPal
+     * rewrite billing address by paypal
+     * save old billing address for new customer
+     * export shipping address in case address absence
+     *
      * @param string $token
      */
     public function returnFromPaypal($token)
@@ -347,10 +357,18 @@ class Mage_Paypal_Model_Express_Checkout
         $this->_getApi();
         $this->_api->setToken($token)
             ->callGetExpressCheckoutDetails();
+        $quote = $this->_quote;
 
         // import billing address
-        $billingAddress = $this->_quote->getBillingAddress();
+        $billingAddress = $quote->getBillingAddress();
         $exportedBillingAddress = $this->_api->getExportedBillingAddress();
+        $quote->setCustomerEmail($billingAddress->getEmail());
+        $quote->setCustomerPrefix($billingAddress->getPrefix());
+        $quote->setCustomerFirstname($billingAddress->getFirstname());
+        $quote->setCustomerMiddlename($billingAddress->getMiddlename());
+        $quote->setCustomerLastname($billingAddress->getLastname());
+        $quote->setCustomerSuffix($billingAddress->getSuffix());
+        $quote->setCustomerNote($exportedBillingAddress->getData('note'));
         foreach ($exportedBillingAddress->getExportedKeys() as $key) {
             if (!$billingAddress->getDataUsingMethod($key)) {
                 $billingAddress->setDataUsingMethod($key, $exportedBillingAddress->getData($key));
@@ -359,14 +377,15 @@ class Mage_Paypal_Model_Express_Checkout
 
         // import shipping address
         $exportedShippingAddress = $this->_api->getExportedShippingAddress();
-        if (!$this->_quote->getIsVirtual()) {
-            $shippingAddress = $this->_quote->getShippingAddress();
+        if (!$quote->getIsVirtual()) {
+            $shippingAddress = $quote->getShippingAddress();
             if ($shippingAddress) {
                 if ($exportedShippingAddress) {
                     foreach ($exportedShippingAddress->getExportedKeys() as $key) {
                         $shippingAddress->setDataUsingMethod($key, $exportedShippingAddress->getData($key));
                     }
                     $shippingAddress->setCollectShippingRates(true);
+                    $shippingAddress->setSameAsBilling(0);
                 }
 
                 // import shipping method
@@ -377,7 +396,7 @@ class Mage_Paypal_Model_Express_Checkout
                         $shippingAddress->setShippingMethod($code)->setCollectShippingRates(true);
                     }
                 }
-                $this->_quote->getPayment()->setAdditionalInformation(
+                $quote->getPayment()->setAdditionalInformation(
                     self::PAYMENT_INFO_TRANSPORT_SHIPPING_METHOD,
                     $code
                 );
@@ -386,13 +405,13 @@ class Mage_Paypal_Model_Express_Checkout
         $this->_ignoreAddressValidation();
 
         // import payment info
-        $payment = $this->_quote->getPayment();
+        $payment = $quote->getPayment();
         $payment->setMethod($this->_methodType);
         Mage::getSingleton('paypal/info')->importToPayment($this->_api, $payment);
         $payment->setAdditionalInformation(self::PAYMENT_INFO_TRANSPORT_PAYER_ID, $this->_api->getPayerId())
             ->setAdditionalInformation(self::PAYMENT_INFO_TRANSPORT_TOKEN, $token)
         ;
-        $this->_quote->collectTotals()->save();
+        $quote->collectTotals()->save();
     }
 
     /**
@@ -484,10 +503,18 @@ class Mage_Paypal_Model_Express_Checkout
             $this->updateShippingMethod($shippingMethodCode);
         }
 
-        if (!$this->_quote->getCustomerId()) {
-            $this->_quote->setCustomerIsGuest(true)
-                ->setCustomerGroupId(Mage_Customer_Model_Group::NOT_LOGGED_IN_ID)
-                ->setCustomerEmail($this->_quote->getBillingAddress()->getEmail());
+        $isNewCustomer = false;
+        switch ($this->_quote->getCheckoutMethod()) {
+            case Mage_Checkout_Model_Type_Onepage::METHOD_GUEST:
+                $this->_prepareGuestQuote();
+                break;
+            case Mage_Checkout_Model_Type_Onepage::METHOD_REGISTER:
+                $this->_prepareNewCustomerQuote();
+                $isNewCustomer = true;
+                break;
+            default:
+                $this->_prepareCustomerQuote();
+                break;
         }
 
         $this->_ignoreAddressValidation();
@@ -495,6 +522,15 @@ class Mage_Paypal_Model_Express_Checkout
         $service = Mage::getModel('sales/service_quote', $this->_quote);
         $service->submitAll();
         $this->_quote->save();
+
+        if ($isNewCustomer) {
+            try {
+                $this->_involveNewCustomer();
+            } catch (Exception $e) {
+                Mage::logException($e);
+            }
+        }
+
         $this->_recurringPaymentProfiles = $service->getRecurringPaymentProfiles();
         // TODO: send recurring profile emails
 
@@ -719,4 +755,144 @@ class Mage_Paypal_Model_Express_Checkout
         }
         return '';
     }
+
+    /**
+     * Prepare quote for guest checkout order submit
+     *
+     * @return Mage_Paypal_Model_Express_Checkout
+     */
+    protected function _prepareGuestQuote()
+    {
+        $quote = $this->_quote;
+        $quote->setCustomerId(null)
+            ->setCustomerEmail($quote->getBillingAddress()->getEmail())
+            ->setCustomerIsGuest(true)
+            ->setCustomerGroupId(Mage_Customer_Model_Group::NOT_LOGGED_IN_ID);
+        return $this;
+    }
+
+    /**
+     * Prepare quote for customer registration and customer order submit
+     * and restore magento customer data from quote
+     *
+     * @return Mage_Paypal_Model_Express_Checkout
+     */
+    protected function _prepareNewCustomerQuote()
+    {
+        $quote      = $this->_quote;
+        $billing    = $quote->getBillingAddress();
+        $shipping   = $quote->isVirtual() ? null : $quote->getShippingAddress();
+
+        $customer = $quote->getCustomer();
+        /** @var $customer Mage_Customer_Model_Customer */
+        $customerBilling = $billing->exportCustomerAddress();
+        $customer->addAddress($customerBilling);
+        $billing->setCustomerAddress($customerBilling);
+        $customerBilling->setIsDefaultBilling(true);
+        if ($shipping && !$shipping->getSameAsBilling()) {
+            $customerShipping = $shipping->exportCustomerAddress();
+            $customer->addAddress($customerShipping);
+            $shipping->setCustomerAddress($customerShipping);
+            $customerShipping->setIsDefaultShipping(true);
+        } elseif ($shipping) {
+            $customerBilling->setIsDefaultShipping(true);
+        }
+        /**
+         * @todo integration with dynamica attributes customer_dob, customer_taxvat, customer_gender
+         */
+        if ($quote->getCustomerDob() && !$billing->getCustomerDob()) {
+            $billing->setCustomerDob($quote->getCustomerDob());
+        }
+
+        if ($quote->getCustomerTaxvat() && !$billing->getCustomerTaxvat()) {
+            $billing->setCustomerTaxvat($quote->getCustomerTaxvat());
+        }
+
+        if ($quote->getCustomerGender() && !$billing->getCustomerGender()) {
+            $billing->setCustomerGender($quote->getCustomerGender());
+        }
+
+        Mage::helper('core')->copyFieldset('checkout_onepage_billing', 'to_customer', $billing, $customer);
+        $customer->setEmail($quote->getCustomerEmail());
+        $customer->setPrefix($quote->getCustomerPrefix());
+        $customer->setFirstname($quote->getCustomerFirstname());
+        $customer->setMiddlename($quote->getCustomerMiddlename());
+        $customer->setLastname($quote->getCustomerLastname());
+        $customer->setSuffix($quote->getCustomerSuffix());
+        $customer->setPassword($customer->decryptPassword($quote->getPasswordHash()));
+        $customer->setPasswordHash($customer->hashPassword($customer->getPassword()));
+        $quote->setCustomer($customer)
+            ->setCustomerId(true);
+        $quote->setPasswordHash('');
+
+        return $this;
+    }
+
+    /**
+     * Prepare quote for customer order submit
+     *
+     * @return Mage_Paypal_Model_Express_Checkout
+     */
+    protected function _prepareCustomerQuote()
+    {
+        $quote      = $this->_quote;
+        $billing    = $quote->getBillingAddress();
+        $shipping   = $quote->isVirtual() ? null : $quote->getShippingAddress();
+
+        $customer = $this->getCustomerSession()->getCustomer();
+        if (!$billing->getCustomerId() || $billing->getSaveInAddressBook()) {
+            $customerBilling = $billing->exportCustomerAddress();
+            $customer->addAddress($customerBilling);
+            $billing->setCustomerAddress($customerBilling);
+        }
+        if ($shipping && ((!$shipping->getCustomerId() && !$shipping->getSameAsBilling())
+            || (!$shipping->getSameAsBilling() && $shipping->getSaveInAddressBook()))) {
+            $customerShipping = $shipping->exportCustomerAddress();
+            $customer->addAddress($customerShipping);
+            $shipping->setCustomerAddress($customerShipping);
+        }
+
+        if (isset($customerBilling) && !$customer->getDefaultBilling()) {
+            $customerBilling->setIsDefaultBilling(true);
+        }
+        if ($shipping && isset($customerBilling) && !$customer->getDefaultShipping() && $shipping->getSameAsBilling()) {
+            $customerBilling->setIsDefaultShipping(true);
+        } elseif ($shipping && isset($customerShipping) && !$customer->getDefaultShipping()) {
+            $customerShipping->setIsDefaultShipping(true);
+        }
+        $quote->setCustomer($customer);
+
+        return $this;
+    }
+
+    /**
+     * Involve new customer to system
+     *
+     * @return Mage_Paypal_Model_Express_Checkout
+     */
+    protected function _involveNewCustomer()
+    {
+        $customer = $this->_quote->getCustomer();
+        if ($customer->isConfirmationRequired()) {
+            $customer->sendNewAccountEmail('confirmation');
+            $url = Mage::helper('customer')->getEmailConfirmationUrl($customer->getEmail());
+            $this->getCustomerSession()->addSuccess(
+                Mage::helper('customer')->__('Account confirmation is required. Please, check your e-mail for confirmation link. To resend confirmation email please <a href="%s">click here</a>.', $url)
+            );
+        } else {
+            $customer->sendNewAccountEmail();
+            $this->getCustomerSession()->loginById($customer->getId());
+        }
+        return $this;
+    }
+
+    /**
+     * Get customer session object
+     *
+     * @return Mage_Customer_Model_Session
+     */
+    public function getCustomerSession()
+    {
+        return $this->_customerSession;
+    }
 }
diff --git app/code/core/Mage/XmlConnect/controllers/ReviewController.php app/code/core/Mage/XmlConnect/controllers/ReviewController.php
index 0a0d2f82688..93de695ded2 100644
--- app/code/core/Mage/XmlConnect/controllers/ReviewController.php
+++ app/code/core/Mage/XmlConnect/controllers/ReviewController.php
@@ -143,8 +143,9 @@ class Mage_XmlConnect_ReviewController extends Mage_XmlConnect_Controller_Action
         if (($product = $this->_initProduct()) && !empty($data)) {
             /** @var $review Mage_Review_Model_Review */
             $review     = Mage::getModel('review/review')->setData($data);
+            $validate = array_key_exists('review_id', $data) ? false : $review->validate();
 
-            if (($validate = $review->validate()) === true) {
+            if ($validate === true) {
                 try {
                     $review->setEntityId($review->getEntityIdByCode(Mage_Review_Model_Review::ENTITY_PRODUCT_CODE))
                         ->setEntityPkValue($product->getId())
diff --git app/code/core/Zend/Filter/PregReplace.php app/code/core/Zend/Filter/PregReplace.php
index 586c0fe20a0..d6fa2dac0ec 100644
--- app/code/core/Zend/Filter/PregReplace.php
+++ app/code/core/Zend/Filter/PregReplace.php
@@ -21,7 +21,8 @@
 
 /**
  * This class replaces default Zend_Filter_PregReplace because of problem described in MPERF-10057
- * The only difference between current class and original one is overwritten implementation of filter method
+ * The only difference between current class and original one is overwritten implementation of filter method and add new
+ * method _isValidMatchPattern
  *
  * @see Zend_Filter_Interface
  */
@@ -170,14 +171,31 @@ class Zend_Filter_PregReplace implements Zend_Filter_Interface
             #require_once 'Zend/Filter/Exception.php';
             throw new Zend_Filter_Exception(get_class($this) . ' does not have a valid MatchPattern set.');
         }
-        $firstDilimeter = substr($this->_matchPattern, 0, 1);
-        $partsOfRegex = explode($firstDilimeter, $this->_matchPattern);
-        $modifiers = array_pop($partsOfRegex);
-        if ($modifiers != str_replace('e', '', $modifiers)) {
+        if (!$this->_isValidMatchPattern()) {
             throw new Zend_Filter_Exception(get_class($this) . ' uses deprecated modifier "/e".');
         }
 
         return preg_replace($this->_matchPattern, $this->_replacement, $value);
     }
 
+    /**
+     * Method for checking correctness of match pattern
+     *
+     * @return bool
+     */
+    public function _isValidMatchPattern()
+    {
+        $result = true;
+        foreach ((array) $this->_matchPattern as $pattern) {
+            $firstDilimeter = substr($pattern, 0, 1);
+            $partsOfRegex = explode($firstDilimeter, $pattern);
+            $modifiers = array_pop($partsOfRegex);
+            if ($modifiers != str_replace('e', '', $modifiers)) {
+                $result = false;
+                break;
+            }
+        }
+
+        return $result;
+    }
 }
diff --git app/design/adminhtml/default/default/template/bundle/product/edit/bundle/option.phtml app/design/adminhtml/default/default/template/bundle/product/edit/bundle/option.phtml
index 412e29a2109..a8d149dd8fb 100644
--- app/design/adminhtml/default/default/template/bundle/product/edit/bundle/option.phtml
+++ app/design/adminhtml/default/default/template/bundle/product/edit/bundle/option.phtml
@@ -209,14 +209,16 @@ var optionIndex = 0;
 bOption = new Bundle.Option(optionTemplate);
 //adding data to templates
 <?php foreach ($this->getOptions() as $_option): ?>
-optionIndex = bOption.add(<?php echo $_option->toJson() ?>);
-<?php if ($_option->getSelections()):?>
-    <?php foreach ($_option->getSelections() as $_selection): ?>
-    <?php $_selection->setName($this->escapeHtml($_selection->getName())); ?>
-    <?php $_selection->setSku($this->escapeHtml($_selection->getSku())); ?>
-bSelection.addRow(optionIndex, <?php echo $_selection->toJson() ?>);
-    <?php endforeach; ?>
-<?php endif; ?>
+    <?php $_option->setDefaultTitle($this->escapeHtml($_option->getDefaultTitle())); ?>
+    <?php $_option->setTitle($this->escapeHtml($_option->getTitle())); ?>
+    optionIndex = bOption.add(<?php echo $_option->toJson() ?>);
+    <?php if ($_option->getSelections()):?>
+        <?php foreach ($_option->getSelections() as $_selection): ?>
+        <?php $_selection->setName($this->escapeHtml($_selection->getName())); ?>
+        <?php $_selection->setSku($this->escapeHtml($_selection->getSku())); ?>
+        bSelection.addRow(optionIndex, <?php echo $_selection->toJson() ?>);
+        <?php endforeach; ?>
+    <?php endif; ?>
 <?php endforeach; ?>
 /**
  * Adding event on price type select box of product to hide or show prices for selections
diff --git app/design/adminhtml/default/default/template/bundle/sales/creditmemo/create/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/creditmemo/create/items/renderer.phtml
index 6d6ceb2b377..163eb4b2682 100644
--- app/design/adminhtml/default/default/template/bundle/sales/creditmemo/create/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/creditmemo/create/items/renderer.phtml
@@ -49,7 +49,7 @@
     <?php if ($_item->getOrderItem()->getParentItem()): ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
diff --git app/design/adminhtml/default/default/template/bundle/sales/creditmemo/view/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/creditmemo/view/items/renderer.phtml
index 3cdbd82cc20..0e71cc85c86 100644
--- app/design/adminhtml/default/default/template/bundle/sales/creditmemo/view/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/creditmemo/view/items/renderer.phtml
@@ -49,7 +49,7 @@
     <?php if ($_item->getOrderItem()->getParentItem()): ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
diff --git app/design/adminhtml/default/default/template/bundle/sales/invoice/create/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/invoice/create/items/renderer.phtml
index 8a8eb7baf6a..a8a53b4e1b6 100644
--- app/design/adminhtml/default/default/template/bundle/sales/invoice/create/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/invoice/create/items/renderer.phtml
@@ -49,7 +49,7 @@
         <?php $attributes = $this->getSelectionAttributes($_item) ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
diff --git app/design/adminhtml/default/default/template/bundle/sales/invoice/view/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/invoice/view/items/renderer.phtml
index 7f703271ec4..ca7c1c8a6a4 100644
--- app/design/adminhtml/default/default/template/bundle/sales/invoice/view/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/invoice/view/items/renderer.phtml
@@ -49,7 +49,7 @@
         <?php $attributes = $this->getSelectionAttributes($_item) ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
diff --git app/design/adminhtml/default/default/template/bundle/sales/order/view/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/order/view/items/renderer.phtml
index c87a58266d3..57a94d3fec7 100644
--- app/design/adminhtml/default/default/template/bundle/sales/order/view/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/order/view/items/renderer.phtml
@@ -49,7 +49,7 @@
     <?php if ($_item->getParentItem()): ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
             <td>&nbsp;</td>
diff --git app/design/adminhtml/default/default/template/bundle/sales/shipment/create/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/shipment/create/items/renderer.phtml
index ef66b81bc01..f0a1c319771 100644
--- app/design/adminhtml/default/default/template/bundle/sales/shipment/create/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/shipment/create/items/renderer.phtml
@@ -49,7 +49,7 @@
         <?php $attributes = $this->getSelectionAttributes($_item) ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td>&nbsp;</td>
             <td class="last">&nbsp;</td>
         </tr>
diff --git app/design/adminhtml/default/default/template/bundle/sales/shipment/view/items/renderer.phtml app/design/adminhtml/default/default/template/bundle/sales/shipment/view/items/renderer.phtml
index 4af3d9aa281..448b2f033bf 100644
--- app/design/adminhtml/default/default/template/bundle/sales/shipment/view/items/renderer.phtml
+++ app/design/adminhtml/default/default/template/bundle/sales/shipment/view/items/renderer.phtml
@@ -50,7 +50,7 @@
         <?php $attributes = $this->getSelectionAttributes($_item) ?>
         <?php if ($_prevOptionId != $attributes['option_id']): ?>
         <tr>
-            <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+            <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
             <td class="last">&nbsp;</td>
         </tr>
         <?php $_prevOptionId = $attributes['option_id'] ?>
diff --git app/design/adminhtml/default/default/template/catalog/product/helper/gallery.phtml app/design/adminhtml/default/default/template/catalog/product/helper/gallery.phtml
index 7e9bedf7d2a..b5c6510de4c 100644
--- app/design/adminhtml/default/default/template/catalog/product/helper/gallery.phtml
+++ app/design/adminhtml/default/default/template/catalog/product/helper/gallery.phtml
@@ -58,8 +58,8 @@ $_block = $this;
             <th><?php echo Mage::helper('catalog')->__('Image') ?></th>
             <th><?php echo Mage::helper('catalog')->__('Label') ?></th>
             <th><?php echo Mage::helper('catalog')->__('Sort Order') ?></th>
-            <?php foreach ($_block->getImageTypes() as $typeId=>$type): ?>
-            <th><?php echo $type['label'] ?></th>
+            <?php foreach ($_block->getImageTypes() as $typeId => $type): ?>
+                <th><?php echo $this->escapeHtml($type['label']); ?></th>
             <?php endforeach; ?>
             <th><?php echo Mage::helper('catalog')->__('Exclude') ?></th>
             <th class="last"><?php echo Mage::helper('catalog')->__('Remove') ?></th>
diff --git app/design/adminhtml/default/default/template/downloadable/product/composite/fieldset/downloadable.phtml app/design/adminhtml/default/default/template/downloadable/product/composite/fieldset/downloadable.phtml
index ecc6bf86ae9..2ee8db0fb3b 100644
--- app/design/adminhtml/default/default/template/downloadable/product/composite/fieldset/downloadable.phtml
+++ app/design/adminhtml/default/default/template/downloadable/product/composite/fieldset/downloadable.phtml
@@ -44,7 +44,7 @@
                         <?php endif; ?>
                         <span class="label">
                         <label for="links_<?php echo $_link->getId() ?>">
-                        <?php echo $_link->getTitle() ?>
+                        <?php echo $this->escapeHtml($_link->getTitle()); ?>
                         </label>
                         <?php if ($_link->getSampleFile() || $_link->getSampleUrl()): ?>
                             &nbsp;(<a href="<?php echo $this->getLinkSamlpeUrl($_link) ?>" <?php echo $this->getIsOpenInNewWindow()?'onclick="this.target=\'_blank\'"':''; ?>><?php echo Mage::helper('downloadable')->__('sample') ?></a>)
diff --git app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/creditmemo/name.phtml app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/creditmemo/name.phtml
index 1f75148065f..71f3b4f57d0 100644
--- app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/creditmemo/name.phtml
+++ app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/creditmemo/name.phtml
@@ -54,7 +54,7 @@
         <dl class="item-options">
             <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
             <?php foreach ($this->getLinks()->getPurchasedItems() as $_link): ?>
-                <dd><?php echo $_link->getLinkTitle() ?></dd>
+                <dd><?php echo $this->escapeHtml($_link->getLinkTitle()); ?></dd>
             <?php endforeach; ?>
         </dl>
     <?php endif; ?>
diff --git app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/invoice/name.phtml app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/invoice/name.phtml
index 342a7746a38..de59e99414f 100644
--- app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/invoice/name.phtml
+++ app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/invoice/name.phtml
@@ -54,7 +54,7 @@
         <dl class="item-options">
             <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
             <?php foreach ($this->getLinks()->getPurchasedItems() as $_link): ?>
-                <dd><?php echo $_link->getLinkTitle() ?> (<?php echo $_link->getNumberOfDownloadsBought()?$_link->getNumberOfDownloadsBought():Mage::helper('downloadable')->__('Unlimited') ?>)</dd>
+                <dd><?php echo $this->escapeHtml($_link->getLinkTitle()); ?> (<?php echo $_link->getNumberOfDownloadsBought()?$_link->getNumberOfDownloadsBought():Mage::helper('downloadable')->__('Unlimited') ?>)</dd>
             <?php endforeach; ?>
         </dl>
     <?php endif; ?>
diff --git app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/name.phtml app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/name.phtml
index 4015ea8f618..489676082b6 100644
--- app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/name.phtml
+++ app/design/adminhtml/default/default/template/downloadable/sales/items/column/downloadable/name.phtml
@@ -54,7 +54,7 @@
         <dl class="item-options">
             <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
             <?php foreach ($this->getLinks()->getPurchasedItems() as $_link): ?>
-                <dd><?php echo $_link->getLinkTitle() ?> (<?php echo $_link->getNumberOfDownloadsUsed() . ' / ' . ($_link->getNumberOfDownloadsBought()?$_link->getNumberOfDownloadsBought():Mage::helper('downloadable')->__('U')) ?>)</dd>
+                <dd><?php echo $this->escapeHtml($_link->getLinkTitle()); ?> (<?php echo $_link->getNumberOfDownloadsUsed() . ' / ' . ($_link->getNumberOfDownloadsBought()?$_link->getNumberOfDownloadsBought():Mage::helper('downloadable')->__('U')) ?>)</dd>
             <?php endforeach; ?>
         </dl>
     <?php endif; ?>
diff --git app/design/frontend/base/default/template/bundle/email/order/items/creditmemo/default.phtml app/design/frontend/base/default/template/bundle/email/order/items/creditmemo/default.phtml
index 6a558be08a5..53b2de7d6a3 100644
--- app/design/frontend/base/default/template/bundle/email/order/items/creditmemo/default.phtml
+++ app/design/frontend/base/default/template/bundle/email/order/items/creditmemo/default.phtml
@@ -43,7 +43,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td align="left" valign="top" style="padding:3px 9px"><strong><?php echo $attributes['option_label'] ?></strong></td>
+        <td align="left" valign="top" style="padding:3px 9px"><strong><?php echo $this->escapeHtml($attributes['option_label']); ?></strong></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/email/order/items/invoice/default.phtml app/design/frontend/base/default/template/bundle/email/order/items/invoice/default.phtml
index a7f1b5822ad..df910951e33 100644
--- app/design/frontend/base/default/template/bundle/email/order/items/invoice/default.phtml
+++ app/design/frontend/base/default/template/bundle/email/order/items/invoice/default.phtml
@@ -44,7 +44,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $attributes['option_label'] ?></em></strong></td>
+        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $this->escapeHtml($attributes['option_label']); ?></em></strong></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/email/order/items/order/default.phtml app/design/frontend/base/default/template/bundle/email/order/items/order/default.phtml
index 253685b9801..536858891e3 100644
--- app/design/frontend/base/default/template/bundle/email/order/items/order/default.phtml
+++ app/design/frontend/base/default/template/bundle/email/order/items/order/default.phtml
@@ -44,7 +44,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $attributes['option_label'] ?></em></strong></td>
+        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $this->escapeHtml($attributes['option_label']); ?></em></strong></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/email/order/items/shipment/default.phtml app/design/frontend/base/default/template/bundle/email/order/items/shipment/default.phtml
index 8609a493be3..a7722bc5881 100644
--- app/design/frontend/base/default/template/bundle/email/order/items/shipment/default.phtml
+++ app/design/frontend/base/default/template/bundle/email/order/items/shipment/default.phtml
@@ -43,7 +43,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $attributes['option_label'] ?></em></strong></td>
+        <td align="left" valign="top" style="padding:3px 9px"><strong><em><?php echo $this->escapeHtml($attributes['option_label']); ?></em></strong></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
     </tr>
diff --git app/design/frontend/base/default/template/bundle/sales/order/creditmemo/items/renderer.phtml app/design/frontend/base/default/template/bundle/sales/order/creditmemo/items/renderer.phtml
index 111963b77e3..cfb3f28e9f2 100644
--- app/design/frontend/base/default/template/bundle/sales/order/creditmemo/items/renderer.phtml
+++ app/design/frontend/base/default/template/bundle/sales/order/creditmemo/items/renderer.phtml
@@ -45,7 +45,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+        <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/sales/order/invoice/items/renderer.phtml app/design/frontend/base/default/template/bundle/sales/order/invoice/items/renderer.phtml
index 1f0cf366ee2..2ae84b6a4d0 100644
--- app/design/frontend/base/default/template/bundle/sales/order/invoice/items/renderer.phtml
+++ app/design/frontend/base/default/template/bundle/sales/order/invoice/items/renderer.phtml
@@ -45,7 +45,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+        <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/sales/order/items/renderer.phtml app/design/frontend/base/default/template/bundle/sales/order/items/renderer.phtml
index 1be38981a82..cedb4495ad8 100644
--- app/design/frontend/base/default/template/bundle/sales/order/items/renderer.phtml
+++ app/design/frontend/base/default/template/bundle/sales/order/items/renderer.phtml
@@ -43,7 +43,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr<?php if ($_item->getLastRow()) echo 'class="last"'; ?>>
-        <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+        <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
diff --git app/design/frontend/base/default/template/bundle/sales/order/shipment/items/renderer.phtml app/design/frontend/base/default/template/bundle/sales/order/shipment/items/renderer.phtml
index 8f1b54a562a..95465e47219 100644
--- app/design/frontend/base/default/template/bundle/sales/order/shipment/items/renderer.phtml
+++ app/design/frontend/base/default/template/bundle/sales/order/shipment/items/renderer.phtml
@@ -44,7 +44,7 @@
     <?php $attributes = $this->getSelectionAttributes($_item) ?>
     <?php if ($_prevOptionId != $attributes['option_id']): ?>
     <tr>
-        <td><div class="option-label"><?php echo $attributes['option_label'] ?></div></td>
+        <td><div class="option-label"><?php echo $this->escapeHtml($attributes['option_label']); ?></div></td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
     </tr>
diff --git app/design/frontend/base/default/template/downloadable/catalog/product/links.phtml app/design/frontend/base/default/template/downloadable/catalog/product/links.phtml
index 5617f1f77fd..f3f9468ca29 100644
--- app/design/frontend/base/default/template/downloadable/catalog/product/links.phtml
+++ app/design/frontend/base/default/template/downloadable/catalog/product/links.phtml
@@ -40,7 +40,7 @@
                     <?php endif; ?>
                     <span class="label">
                         <label for="links_<?php echo $_link->getId() ?>">
-                            <?php echo $_link->getTitle() ?>
+                            <?php echo $this->escapeHtml($_link->getTitle()); ?>
                         </label>
                             <?php if ($_link->getSampleFile() || $_link->getSampleUrl()): ?>
                                 &nbsp;(<a href="<?php echo $this->getLinkSamlpeUrl($_link) ?>" <?php echo $this->getIsOpenInNewWindow()?'onclick="this.target=\'_blank\'"':''; ?>><?php echo Mage::helper('downloadable')->__('sample') ?></a>)
diff --git app/design/frontend/base/default/template/downloadable/checkout/cart/item/default.phtml app/design/frontend/base/default/template/downloadable/checkout/cart/item/default.phtml
index 72fa1f054fa..7d56582c5f3 100644
--- app/design/frontend/base/default/template/downloadable/checkout/cart/item/default.phtml
+++ app/design/frontend/base/default/template/downloadable/checkout/cart/item/default.phtml
@@ -55,7 +55,7 @@
         <dl class="item-options">
             <dt><?php echo $this->getLinksTitle() ?></dt>
             <?php foreach ($links as $link): ?>
-                <dd><?php echo $link->getTitle() ?></dd>
+                <dd><?php echo $this->escapeHtml($link->getTitle()); ?></dd>
             <?php endforeach; ?>
         </dl>
         <?php endif; ?>
diff --git app/design/frontend/base/default/template/downloadable/checkout/multishipping/item/downloadable.phtml app/design/frontend/base/default/template/downloadable/checkout/multishipping/item/downloadable.phtml
index dea67f8ffde..75402507088 100644
--- app/design/frontend/base/default/template/downloadable/checkout/multishipping/item/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/checkout/multishipping/item/downloadable.phtml
@@ -48,9 +48,9 @@
     <!-- downloadable -->
     <?php if ($links = $this->getLinks()): ?>
     <dl class="item-options">
-        <dt><?php echo $this->getLinksTitle() ?></dt>
+        <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
         <?php foreach ($links as $link): ?>
-            <dd><?php echo $link->getTitle() ?></dd>
+            <dd><?php echo $this->escapeHtml($link->getTitle()); ?></dd>
         <?php endforeach; ?>
     </dl>
     <?php endif; ?>
diff --git app/design/frontend/base/default/template/downloadable/checkout/onepage/review/item.phtml app/design/frontend/base/default/template/downloadable/checkout/onepage/review/item.phtml
index 3834a56e479..6d7e10fd9a2 100644
--- app/design/frontend/base/default/template/downloadable/checkout/onepage/review/item.phtml
+++ app/design/frontend/base/default/template/downloadable/checkout/onepage/review/item.phtml
@@ -50,7 +50,7 @@
         <dl class="item-options">
             <dt><?php echo $this->getLinksTitle() ?></dt>
             <?php foreach ($links as $link): ?>
-                <dd><?php echo $link->getTitle() ?></dd>
+                <dd><?php echo $this->escapeHtml($link->getTitle()); ?></dd>
             <?php endforeach; ?>
         </dl>
         <?php endif; ?>
diff --git app/design/frontend/base/default/template/downloadable/email/order/items/creditmemo/downloadable.phtml app/design/frontend/base/default/template/downloadable/email/order/items/creditmemo/downloadable.phtml
index 8f15e073a46..31613236e84 100644
--- app/design/frontend/base/default/template/downloadable/email/order/items/creditmemo/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/email/order/items/creditmemo/downloadable.phtml
@@ -39,7 +39,7 @@
         <?php endif; ?>
         <?php if ($links = $this->getLinks()->getPurchasedItems()): ?>
         <dl style="margin:0; padding:0;">
-            <dt><strong><em><?php echo $this->getLinksTitle() ?></em></strong></dt>
+            <dt><strong><em><?php echo $this->escapeHtml($this->getLinksTitle()); ?></em></strong></dt>
             <?php foreach ($links as $link): ?>
                 <dd style="margin:0; padding:0 0 0 9px;"><?php echo $link->getLinkTitle() ?></dd>
             <?php endforeach; ?>
diff --git app/design/frontend/base/default/template/downloadable/email/order/items/invoice/downloadable.phtml app/design/frontend/base/default/template/downloadable/email/order/items/invoice/downloadable.phtml
index 83e5d44259e..ad1e6e33f60 100644
--- app/design/frontend/base/default/template/downloadable/email/order/items/invoice/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/email/order/items/invoice/downloadable.phtml
@@ -39,7 +39,7 @@
         <?php endif; ?>
         <?php if ($links = $this->getLinks()->getPurchasedItems()): ?>
         <dl style="margin:0; padding:0;">
-            <dt><strong><em><?php echo $this->getLinksTitle() ?></em></strong></dt>
+            <dt><strong><em><?php echo $this->escapeHtml($this->getLinksTitle()); ?></em></strong></dt>
             <?php foreach ($links as $link): ?>
                 <dd style="margin:0; padding:0 0 0 9px;">
                     <?php echo $link->getLinkTitle() ?>&nbsp;
diff --git app/design/frontend/base/default/template/downloadable/email/order/items/order/downloadable.phtml app/design/frontend/base/default/template/downloadable/email/order/items/order/downloadable.phtml
index ad05e178eec..394a179b894 100644
--- app/design/frontend/base/default/template/downloadable/email/order/items/order/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/email/order/items/order/downloadable.phtml
@@ -39,7 +39,7 @@
         <?php endif; ?>
         <?php if ($links = $this->getLinks()->getPurchasedItems()): ?>
         <dl style="margin:0; padding:0;">
-            <dt><strong><em><?php echo $this->getLinksTitle() ?></em></strong></dt>
+            <dt><strong><em><?php echo $this->escapeHtml($this->getLinksTitle()); ?></em></strong></dt>
             <?php foreach ($links as $link): ?>
                 <dd style="margin:0; padding:0 0 0 9px;">
                     <?php echo $link->getLinkTitle() ?>&nbsp;
diff --git app/design/frontend/base/default/template/downloadable/sales/order/creditmemo/items/renderer/downloadable.phtml app/design/frontend/base/default/template/downloadable/sales/order/creditmemo/items/renderer/downloadable.phtml
index fa0a873c958..a1d8c191bf3 100644
--- app/design/frontend/base/default/template/downloadable/sales/order/creditmemo/items/renderer/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/sales/order/creditmemo/items/renderer/downloadable.phtml
@@ -54,9 +54,9 @@
         <!-- downloadable -->
         <?php if ($links = $this->getLinks()): ?>
             <dl class="item-options">
-                <dt><?php echo $this->getLinksTitle() ?></dt>
+                <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
                 <?php foreach ($links->getPurchasedItems() as $link): ?>
-                    <dd><?php echo $link->getLinkTitle() ?></dd>
+                    <dd><?php echo $this->escapeHtml($link->getLinkTitle()); ?></dd>
                 <?php endforeach; ?>
             </dl>
         <?php endif; ?>
diff --git app/design/frontend/base/default/template/downloadable/sales/order/invoice/items/renderer/downloadable.phtml app/design/frontend/base/default/template/downloadable/sales/order/invoice/items/renderer/downloadable.phtml
index 7e0bfa6f1ab..330f2696318 100644
--- app/design/frontend/base/default/template/downloadable/sales/order/invoice/items/renderer/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/sales/order/invoice/items/renderer/downloadable.phtml
@@ -55,9 +55,9 @@
         <!-- downloadable -->
         <?php if ($links = $this->getLinks()): ?>
             <dl class="item-options">
-                <dt><?php echo $this->getLinksTitle() ?></dt>
+                <dt><?php echo $this->escapeHtml($this->getLinksTitle()); ?></dt>
                 <?php foreach ($links->getPurchasedItems() as $link): ?>
-                    <dd><?php echo $link->getLinkTitle() ?></dd>
+                    <dd><?php echo $this->escapeHtml($link->getLinkTitle()); ?></dd>
                 <?php endforeach; ?>
             </dl>
         <?php endif; ?>
diff --git app/design/frontend/base/default/template/downloadable/sales/order/items/renderer/downloadable.phtml app/design/frontend/base/default/template/downloadable/sales/order/items/renderer/downloadable.phtml
index 92468fc05a6..2dd9c207bdc 100644
--- app/design/frontend/base/default/template/downloadable/sales/order/items/renderer/downloadable.phtml
+++ app/design/frontend/base/default/template/downloadable/sales/order/items/renderer/downloadable.phtml
@@ -56,7 +56,7 @@
             <dl class="item-options">
                 <dt><?php echo $this->getLinksTitle() ?></dt>
                 <?php foreach ($links->getPurchasedItems() as $link): ?>
-                    <dd><?php echo $link->getLinkTitle() ?></dd>
+                    <dd><?php echo $this->escapeHtml($link->getLinkTitle()); ?></dd>
                 <?php endforeach; ?>
             </dl>
         <?php endif; ?>
diff --git app/locale/en_US/Mage_Adminhtml.csv app/locale/en_US/Mage_Adminhtml.csv
index 1fbd2547c8b..893597dff9c 100644
--- app/locale/en_US/Mage_Adminhtml.csv
+++ app/locale/en_US/Mage_Adminhtml.csv
@@ -1190,6 +1190,7 @@
 "Yes (302 Found)","Yes (302 Found)"
 "Yes (only price with tax)","Yes (only price with tax)"
 "You cannot delete your own account.","You cannot delete your own account."
+"Disallowed block name for frontend.","Disallowed block name for frontend."
 "You have %s unread message(s).","You have %s unread message(s)."
 "You have logged out.","You have logged out."
 "You have not enough permissions to use this functionality.","You have not enough permissions to use this functionality."
diff --git app/locale/en_US/Mage_Customer.csv app/locale/en_US/Mage_Customer.csv
index 8698177d408..49c7f8b5def 100644
--- app/locale/en_US/Mage_Customer.csv
+++ app/locale/en_US/Mage_Customer.csv
@@ -172,6 +172,7 @@
 "Invalid customer data","Invalid customer data"
 "Invalid email address.","Invalid email address."
 "Invalid login or password.","Invalid login or password."
+"Invalid password reset customer Id.","Invalid password reset customer Id."
 "Invalid store specified, skipping the record.","Invalid store specified, skipping the record."
 "Last Activity","Last Activity"
 "Last Date Subscribed","Last Date Subscribed"
diff --git app/locale/en_US/template/email/admin_new_user_notification.html app/locale/en_US/template/email/admin_new_user_notification.html
new file mode 100644
index 00000000000..adac7395637
--- /dev/null
+++ app/locale/en_US/template/email/admin_new_user_notification.html
@@ -0,0 +1,36 @@
+<!--@subject New Admin Account {{var user.name}} Created. @-->
+<!--@vars
+{"store url=\"\"":"Store Url",
+"var logo_url":"Email Logo Image Url",
+"var logo_alt":"Email Logo Image Alt",
+"htmlescape var=$user.name":"New Admin Name",
+@-->
+
+<!--@styles
+body,td { color:#2f2f2f; font:11px/1.35em Verdana, Arial, Helvetica, sans-serif; }
+@-->
+
+<body style="background:#F6F6F6; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:12px; margin:0; padding:0;">
+<div style="background:#F6F6F6; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:12px; margin:0; padding:0;">
+    <table cellspacing="0" cellpadding="0" border="0" height="100%" width="100%">
+        <tr>
+            <td align="center" valign="top" style="padding:20px 0 20px 0">
+                <!-- [ header starts here] -->
+                <table bgcolor="FFFFFF" cellspacing="0" cellpadding="10" border="0" width="650" style="border:1px solid #E0E0E0;">
+                    <!-- [ middle starts here] -->
+                    <tr>
+                        <td valign="top">
+                            <h1>New admin account notification.</h1>
+                            <p>A new admin account was created for <b>{{htmlescape var=$user.name}}</b> using email: {{htmlescape var=$user.email}}.</p>
+                            <p>If you have not requested this action, please review the list of administrator accounts in <a href="{{store url=""}}">your store</a>.</p>
+                        </td>
+                    </tr>
+                    <tr>
+                        <td bgcolor="#EAEAEA" align="center" style="background:#EAEAEA; text-align:center;"><center><p style="font-size:12px; margin:0;">Thank you again, <strong>{{var store.getFrontendName()}}</strong></p></center></td>
+                    </tr>
+                </table>
+            </td>
+        </tr>
+    </table>
+</div>
+</body>
diff --git downloader/Maged/Controller.php downloader/Maged/Controller.php
index 30f9db35d89..bd1bdaa77e7 100755
--- downloader/Maged/Controller.php
+++ downloader/Maged/Controller.php
@@ -776,6 +776,18 @@ final class Maged_Controller
      */
     public function dispatch()
     {
+        $baseUrl = Mage::getBaseUrl(
+            Mage_Core_Model_Store::URL_TYPE_LINK, Mage::getSingleton('adminhtml/url')->getSecure()
+        );
+        if (strpos($baseUrl, 'https') === 0) {
+            $request = Mage::app()->getRequest();
+            if (!$request->isSecure()) {
+                Mage::app()->getFrontController()->getResponse()
+                    ->setRedirect(rtrim($baseUrl, '/') . $request->getRequestUri(), 301)->sendResponse();
+                exit;
+            }
+        }
+
         header('Content-type: text/html; charset=UTF-8');
 
         $this->setAction();
diff --git skin/adminhtml/default/enterprise/images/placeholder/thumbnail.jpg skin/adminhtml/default/enterprise/images/placeholder/thumbnail.jpg
new file mode 100644
index 0000000000000000000000000000000000000000..4537aa80b31904bd348d03240a3aad0fc1e531b6
GIT binary patch
literal 1110
zcmex=<NpH&0WUXCHwH#VMg|WcWcYuZ!I^=Xi3x;&fCY$HIapa)SXjB(+1WUFxOjND
zxwyG``Gf>``2_j6xdp@o1cgOJMMZh|#U;c<B!omnML>oyG6VInuyV4pa*FVB^NNrR
z{vTiv<Y4e-NMUAFVqg+vWEN!ne}qAvfq{_~=vt72p@5MI=teen4o)s^pn|Oe3`~s7
z%uFoIAXfub*8=4kSOi&x6b&8OgaZ@Vl?p|S8YeE~P<GmQP&DY`2NmO_q9#r*F>wh=
zDOELf4NWZ*Q!{f5ODks=S2uSLPp{yR(6I1`$f)F$)U@=B%&g*)(z5c3%Btp;*0%PJ
z&aO$5r%atTea6gLixw|gx@`H1m8&*w-m-Pu_8mKS9XfpE=&|D`PM*4S`O4L6*Kgds
z_3+W-Cr_U}fAR9w$4{TXeEs(Q$Io9Ne=#yJL%ap|8JfQYf&OA*VPR%r2l<PUsT_!z
z1zA`X4cUYo1KAS`g_VpNIYgW$F5GyKQ`tD^gJ@FGMJ_QFlZUDwL0$v<j5v=qk>xYE
z#}NLy#lXYN2#h>tK?Zw<zYdGKG#Eg5!2~vcriHU!Dn5R1zF<|*xzBP{^(6spO<t4I
zvzfbUQ$;g6Y!<%BI%B?<W&ZaI3%I8QF-fGzbVV^}Eb4+|&I4xyW_?`p&@S}r`|#QC
z<}Xb<v~a0|n_C7$8~cn82K(=sR!OI{FF0K_D>6mEeUilshE*Hy*j(qF+<M;8K|GSV
z$Kb@O;z-ex{S#l_Te>G{;>zIWU6by;Kcgs7b8k_Dmb><W3X897>u;Y^4=QZ3>gxLG
zb~LAWPTFMu-|K$_u<p`W)W8MBg8N?n3M<|J>&3sVi|&{F)wa6-x1>IbVQclj<sU`E
z?*FZ-&AR&j*Zd=)(e+<neqF$Ae*e|<zpvKk{@ZJ}|I(WH`c?7YSMA;Y>&vhI3|<Ty
zYyYjRzqjm0?e#yJ*TD*N+wayNYS6vtD#8#5#Vsj<Az^nP&NVXH`AX}r2xHv$zy6Q3
z*6s(IarJgb&&9Xw?3T|~@LurZ=5sv9%MiWqKSRj=_o3DKK>Pnqc|CigQNw};zM{-)
z+urYu`Lm$7*+J-@wv|SJ=iOV=t}%1XJwEwH$d>>{R}oa~TXD_xFi%&h2qRC}O2PB@
R?3Qo!MRFC;b&UUS0s!NOuyz0d

literal 0
HcmV?d00001

