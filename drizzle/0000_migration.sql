CREATE TABLE IF NOT EXISTS "account" (
	"userId" UUID NOT NULL,
	"type" TEXT NOT NULL,
	"provider" TEXT NOT NULL,
	"providerAccountId" TEXT NOT NULL,
	"refresh_token" TEXT,
	"access_token" TEXT,
	"expires_at" INTEGER,
	"token_type" TEXT,
	"scope" TEXT,
	"id_token" TEXT,
	"session_state" TEXT,
	CONSTRAINT "account_provider_providerAccountId_pk" PRIMARY KEY("provider", "providerAccountId")
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "cart" (
	"id" UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID() NOT NULL,
	"userId" UUID,
	"sessionCartId" TEXT NOT NULL,
	"items" JSON DEFAULT '[]'::JSON NOT NULL,
	"itemsPrice" NUMERIC(12, 2) NOT NULL,
	"shippingPrice" NUMERIC(12, 2) NOT NULL,
	"taxPrice" NUMERIC(12, 2) NOT NULL,
	"totalPrice" NUMERIC(12, 2) NOT NULL,
	"createdAt" TIMESTAMP DEFAULT NOW() NOT NULL
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "orderItems" (
	"orderId" UUID NOT NULL,
	"productId" UUID NOT NULL,
	"qty" INTEGER NOT NULL,
	"price" NUMERIC(12, 2) NOT NULL,
	"name" TEXT NOT NULL,
	"slug" TEXT NOT NULL,
	"image" TEXT NOT NULL,
	CONSTRAINT "orderItems_orderId_productId_pk" PRIMARY KEY("orderId", "productId")
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "order" (
	"id" UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID() NOT NULL,
	"userId" UUID NOT NULL,
	"shippingAddress" JSON NOT NULL,
	"paymentMethod" TEXT NOT NULL,
	"paymentResult" JSON,
	"itemsPrice" NUMERIC(12, 2) NOT NULL,
	"shippingPrice" NUMERIC(12, 2) NOT NULL,
	"taxPrice" NUMERIC(12, 2) NOT NULL,
	"totalPrice" NUMERIC(12, 2) NOT NULL,
	"isPaid" BOOLEAN DEFAULT FALSE NOT NULL,
	"paidAt" TIMESTAMP,
	"isDelivered" BOOLEAN DEFAULT FALSE NOT NULL,
	"deliveredAt" TIMESTAMP,
	"createdAt" TIMESTAMP DEFAULT NOW() NOT NULL
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "product" (
	"id" UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID() NOT NULL,
	"name" TEXT NOT NULL,
	"slug" TEXT NOT NULL,
	"category" TEXT NOT NULL,
	"images" TEXT[] NOT NULL,
	"brand" TEXT NOT NULL,
	"description" TEXT NOT NULL,
	"stock" INTEGER NOT NULL,
	"price" NUMERIC(12, 2) DEFAULT '0' NOT NULL,
	"rating" NUMERIC(3, 2) DEFAULT '0' NOT NULL,
	"numReviews" INTEGER DEFAULT 0 NOT NULL,
	"isFeatured" BOOLEAN DEFAULT FALSE NOT NULL,
	"banner" TEXT,
	"createdAt" TIMESTAMP DEFAULT NOW() NOT NULL
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "reviews" (
	"id" UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID() NOT NULL,
	"userId" UUID NOT NULL,
	"productId" UUID NOT NULL,
	"rating" INTEGER NOT NULL,
	"title" TEXT NOT NULL,
	"slug" TEXT NOT NULL,
	"isVerifiedPurchase" BOOLEAN DEFAULT TRUE NOT NULL,
	"createdAt" TIMESTAMP DEFAULT NOW() NOT NULL
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "session" (
	"sessionToken" TEXT PRIMARY KEY NOT NULL,
	"userId" UUID NOT NULL,
	"expires" TIMESTAMP NOT NULL
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user" (
	"id" UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID() NOT NULL,
	"name" TEXT DEFAULT 'NO_NAME' NOT NULL,
	"email" TEXT NOT NULL,
	"role" TEXT DEFAULT 'user' NOT NULL,
	"password" TEXT,
	"emailVerified" TIMESTAMP,
	"image" TEXT,
	"address" JSON,
	"paymentMethod" TEXT,
	"createdAt" TIMESTAMP DEFAULT NOW()
);

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "verificationToken" (
	"identifier" TEXT NOT NULL,
	"token" TEXT NOT NULL,
	"expires" TIMESTAMP NOT NULL,
	CONSTRAINT "verificationToken_identifier_token_pk" PRIMARY KEY("identifier", "token")
);

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "account"
	ADD CONSTRAINT "account_userId_user_id_fk" FOREIGN KEY (
		"userId"
	)
		REFERENCES "public"."user"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "cart"
	ADD CONSTRAINT "cart_userId_user_id_fk" FOREIGN KEY (
		"userId"
	)
		REFERENCES "public"."user"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "orderItems"
	ADD CONSTRAINT "orderItems_orderId_order_id_fk" FOREIGN KEY (
		"orderId"
	)
		REFERENCES "public"."order"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "orderItems"
	ADD CONSTRAINT "orderItems_productId_product_id_fk" FOREIGN KEY (
		"productId"
	)
		REFERENCES "public"."product"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "order"
	ADD CONSTRAINT "order_userId_user_id_fk" FOREIGN KEY (
		"userId"
	)
		REFERENCES "public"."user"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "reviews"
	ADD CONSTRAINT "reviews_userId_user_id_fk" FOREIGN KEY (
		"userId"
	)
		REFERENCES "public"."user"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "reviews"
	ADD CONSTRAINT "reviews_productId_product_id_fk" FOREIGN KEY (
		"productId"
	)
		REFERENCES "public"."product"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
DO $$ BEGIN

ALTER TABLE "session"
	ADD CONSTRAINT "session_userId_user_id_fk" FOREIGN KEY (
		"userId"
	)
		REFERENCES "public"."user"(
			"id"
		) ON DELETE CASCADE ON UPDATE NO ACTION;

EXCEPTION
WHEN DUPLICATE_OBJECT THEN NULL;

END $$;

--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "product_slug_idx" ON "product" ("slug");

--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "user_email_idx" ON "user" ("email");