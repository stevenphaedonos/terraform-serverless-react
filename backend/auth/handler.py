import requests
import os
from jose import jwk, jwt
from jose.utils import base64url_decode
import time
import re


# The below token validation is based on
# https://github.com/awslabs/aws-support-tools/blob/master/Cognito/decode-verify-jwt/decode-verify-jwt.py
# and https://aws.amazon.com/blogs/mobile/integrating-amazon-cognito-user-pools-with-api-gateway/
def validate_token(token):
    if not token:
        return False

    keys = requests.get(
        f'{os.environ["USER_POOL_ENDPOINT"]}/.well-known/jwks.json'
    ).json()["keys"]

    # Get the kid from the headers prior to verification
    headers = jwt.get_unverified_headers(token)

    # Search for the kid of the token in the downloaded public keys
    try:
        key = next(key for key in keys if key["kid"] == headers["kid"])
    except StopIteration:
        return False

    # Construct the public key
    public_key = jwk.construct(key)

    # Get the last two sections of the token, message and signature (encoded in base64)
    message, encoded_signature = str(token).rsplit(".", 1)

    # Decode the signature
    decoded_signature = base64url_decode(encoded_signature.encode("utf-8"))

    # Verify the signature
    if not public_key.verify(message.encode("utf8"), decoded_signature):
        # Signature verification failed
        return False

    # Signature successfully verified
    claims = jwt.get_unverified_claims(token)

    # Verify the token expiration
    if time.time() > claims["exp"]:
        # Token is expired
        return False

    # Verify the token issuer
    if claims["iss"] != os.environ["USER_POOL_ENDPOINT"]:
        # Token was not issued by this user pool
        return False

    return claims


def authenticate(event, context):
    claims = validate_token(event.get("authorizationToken"))
    if not claims:
        return False

    policy = AuthPolicy(claims["username"])

    method_arn = event["methodArn"].split(":")
    api_gateway = method_arn[5].split("/")
    policy.stage = api_gateway[1]

    policy.awsAccountId = method_arn[4]
    policy.restApiId = api_gateway[0]
    policy.region = method_arn[3]

    policy.allowAllMethods()

    response = policy.build()
    response["context"] = {"cognito:groups": ",".join(claims.get("cognito:groups", []))}

    return response


class HttpVerb:
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    PATCH = "PATCH"
    HEAD = "HEAD"
    DELETE = "DELETE"
    OPTIONS = "OPTIONS"
    ALL = "*"


# The below policy generator was sourced from the Lambda blueprint titled
# "api-gateway-authorizer-python"
class AuthPolicy(object):
    # The principal used for the policy, this should be a unique identifier for the end user.
    principalId = ""
    # The policy version used for the evaluation. This should always be '2012-10-17'
    version = "2012-10-17"
    # The regular expression used to validate resource paths for the policy
    pathRegex = "^[/.a-zA-Z0-9-\*]+$"

    """Internal lists of allowed and denied methods.

    These are lists of objects and each object has 2 properties: A resource
    ARN and a nullable conditions statement. The build method processes these
    lists and generates the approriate statements for the final policy.
    """
    allowMethods = []
    denyMethods = []

    # The AWS account id the policy will be generated for. This is used to create the method ARNs.
    # By default this is set to '*'
    awsAccountId = "*"
    # The API Gateway API id. By default this is set to '*'
    restApiId = "*"
    # The region where the API is deployed. By default this is set to '*'
    region = "*"
    # The name of the stage used in the policy. By default this is set to '*'
    stage = "*"

    def __init__(self, principal):
        self.principalId = principal
        self.allowMethods = []
        self.denyMethods = []

    def _addMethod(self, effect, verb, resource, conditions):
        """Adds a method to the internal lists of allowed or denied methods. Each object in
        the internal list contains a resource ARN and a condition statement. The condition
        statement can be null."""
        if verb != "*" and not hasattr(HttpVerb, verb):
            raise NameError(
                "Invalid HTTP verb " + verb + ". Allowed verbs in HttpVerb class"
            )
        resourcePattern = re.compile(self.pathRegex)
        if not resourcePattern.match(resource):
            raise NameError(
                "Invalid resource path: "
                + resource
                + ". Path should match "
                + self.pathRegex
            )

        if resource[:1] == "/":
            resource = resource[1:]

        resourceArn = "arn:aws:execute-api:{}:{}:{}/{}/{}/{}".format(
            self.region, self.awsAccountId, self.restApiId, self.stage, verb, resource
        )

        if effect.lower() == "allow":
            self.allowMethods.append(
                {"resourceArn": resourceArn, "conditions": conditions}
            )
        elif effect.lower() == "deny":
            self.denyMethods.append(
                {"resourceArn": resourceArn, "conditions": conditions}
            )

    def _getEmptyStatement(self, effect):
        """Returns an empty statement object prepopulated with the correct action and the
        desired effect."""
        statement = {
            "Action": "execute-api:Invoke",
            "Effect": effect[:1].upper() + effect[1:].lower(),
            "Resource": [],
        }

        return statement

    def _getStatementForEffect(self, effect, methods):
        """This function loops over an array of objects containing a resourceArn and
        conditions statement and generates the array of statements for the policy."""
        statements = []

        if len(methods) > 0:
            statement = self._getEmptyStatement(effect)

            for curMethod in methods:
                if curMethod["conditions"] is None or len(curMethod["conditions"]) == 0:
                    statement["Resource"].append(curMethod["resourceArn"])
                else:
                    conditionalStatement = self._getEmptyStatement(effect)
                    conditionalStatement["Resource"].append(curMethod["resourceArn"])
                    conditionalStatement["Condition"] = curMethod["conditions"]
                    statements.append(conditionalStatement)

            if statement["Resource"]:
                statements.append(statement)

        return statements

    def allowAllMethods(self):
        """Adds a '*' allow to the policy to authorize access to all methods of an API"""
        self._addMethod("Allow", HttpVerb.ALL, "*", [])

    def denyAllMethods(self):
        """Adds a '*' allow to the policy to deny access to all methods of an API"""
        self._addMethod("Deny", HttpVerb.ALL, "*", [])

    def allowMethod(self, verb, resource):
        """Adds an API Gateway method (Http verb + Resource path) to the list of allowed
        methods for the policy"""
        self._addMethod("Allow", verb, resource, [])

    def denyMethod(self, verb, resource):
        """Adds an API Gateway method (Http verb + Resource path) to the list of denied
        methods for the policy"""
        self._addMethod("Deny", verb, resource, [])

    def allowMethodWithConditions(self, verb, resource, conditions):
        """Adds an API Gateway method (Http verb + Resource path) to the list of allowed
        methods and includes a condition for the policy statement. More on AWS policy
        conditions here: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#Condition"""
        self._addMethod("Allow", verb, resource, conditions)

    def denyMethodWithConditions(self, verb, resource, conditions):
        """Adds an API Gateway method (Http verb + Resource path) to the list of denied
        methods and includes a condition for the policy statement. More on AWS policy
        conditions here: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#Condition"""
        self._addMethod("Deny", verb, resource, conditions)

    def build(self):
        """Generates the policy document based on the internal lists of allowed and denied
        conditions. This will generate a policy with two main statements for the effect:
        one statement for Allow and one statement for Deny.
        Methods that includes conditions will have their own statement in the policy."""
        if (self.allowMethods is None or len(self.allowMethods) == 0) and (
            self.denyMethods is None or len(self.denyMethods) == 0
        ):
            raise NameError("No statements defined for the policy")

        policy = {
            "principalId": self.principalId,
            "policyDocument": {"Version": self.version, "Statement": []},
        }

        policy["policyDocument"]["Statement"].extend(
            self._getStatementForEffect("Allow", self.allowMethods)
        )
        policy["policyDocument"]["Statement"].extend(
            self._getStatementForEffect("Deny", self.denyMethods)
        )

        return policy
